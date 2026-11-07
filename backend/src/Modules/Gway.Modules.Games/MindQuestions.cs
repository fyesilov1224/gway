using System.Text.Json;
using System.Text.Json.Nodes;

namespace Gway.Modules.Games;

/// <summary>One generated question: what the app shows (<see cref="Payload"/>) and what only the server knows (<see cref="Solution"/>).</summary>
internal sealed record MindQuestion(int Index, string Kind, int Level, JsonObject Payload, JsonObject Solution, int LimitMs);

/// <summary>How an answer scored.</summary>
internal readonly record struct MindScore(int Points, bool Correct);

/// <summary>
/// Zihin Düellosu questions (docs/ARCHITECTURE.md §3j, Sorular): math, attention (Stroop), memory and reflex ("Işık sırası").
/// The server generates them, never sends a solution before the answer, and scores with its own clock. No database here.
/// </summary>
internal static class MindQuestions
{
    public const string Math = "math";
    public const string Attention = "attention";
    public const string Memory = "memory";
    public const string Reflex = "reflex";

    public static readonly int[] Lengths = [5, 10, 20, 50];

    public static readonly string[] Colors = ["red", "blue", "green", "yellow", "purple", "orange"];
    public static readonly string[] Patterns = ["solid", "striped", "dotted"];
    public static readonly string[] Shapes = ["circle", "square", "triangle", "star"];

    /// <summary>Late answers within this of the limit still count (network); later is a timeout.</summary>
    public const int GraceMs = 2000;

    /// <summary>The app's own timing is trusted down to this much under the server's.</summary>
    public const int ClientSlackMs = 2000;

    /// <summary>A reflex tap faster than this is anticipation, not reaction.</summary>
    public const int MinReactionMs = 120;

    public const int ReflexPenalty = -50;

    /// <summary>Light sequence: the 4×4 field and the colors the lights take in turn.</summary>
    public const int ReflexGrid = 4;
    public static readonly string[] LightColors = ["green", "yellow", "orange"];

    /// <summary>All the lights of a sequence come and go within this.</summary>
    public const int ReflexShowMs = 2000;

    private const string Characters = "ABCDEFGHJKLMNPRSTUVYZ0123456789OQI";

    private static readonly Dictionary<char, string> Similar = new()
    {
        ['O'] = "0Q", ['0'] = "OQ", ['Q'] = "O0", ['1'] = "I7", ['I'] = "1L", ['7'] = "1T", ['5'] = "S", ['S'] = "5", ['8'] = "B3",
        ['B'] = "8", ['3'] = "8", ['2'] = "Z", ['Z'] = "2", ['6'] = "G", ['G'] = "6", ['E'] = "F", ['F'] = "E", ['M'] = "NW",
        ['N'] = "M", ['W'] = "M", ['P'] = "R", ['R'] = "P", ['U'] = "V", ['V'] = "U", ['C'] = "G", ['T'] = "7",
    };

    /// <summary>The level of question <paramref name="index"/> in a match of <paramref name="length"/>: 1 to 4, rising.</summary>
    public static int LevelOf(int index, int length) => 1 + (4 * index / length);

    /// <summary>The kinds in order: every block of four holds each kind once, shuffled.</summary>
    public static string[] KindOrder(int length, Random random)
    {
        var order = new List<string>(length);
        while (order.Count < length)
        {
            string[] block = [Math, Attention, Memory, Reflex];
            random.Shuffle(block);
            order.AddRange(block);
        }
        return [.. order.Take(length)];
    }

    public static List<MindQuestion> Generate(int length, Random random)
    {
        var kinds = KindOrder(length, random);
        return [.. kinds.Select((kind, i) => Create(kind, i, LevelOf(i, length), random))];
    }

    public static MindQuestion Create(string kind, int index, int level, Random random) => kind switch
    {
        Math => MathQuestion(index, level, random),
        Attention => AttentionQuestion(index, level, random),
        Memory => MemoryQuestion(index, level, random),
        _ => ReflexQuestion(index, level, random),
    };

    // -----------------------------------------------------------------------
    // Math: a four-operation expression with precedence; whole numbers only.
    // -----------------------------------------------------------------------

    /// <summary>A term: a number, a product or an exact quotient.</summary>
    private static List<object> Term(bool compound, Random random, int small, int big)
    {
        if (!compound) return [random.Next(small, big + 1)];
        if (random.Next(2) == 0) return [random.Next(2, 13), '×', random.Next(2, 10)];
        var divisor = random.Next(2, 10);
        return [divisor * random.Next(2, 13), '÷', divisor];
    }

    /// <summary>A product or exact quotient with bigger numbers (level 3 and up).</summary>
    private static List<object> HardTerm(Random random)
    {
        if (random.Next(2) == 0) return [random.Next(6, 20), '×', random.Next(3, 10)];
        var divisor = random.Next(3, 13);
        return [divisor * random.Next(4, 16), '÷', divisor];
    }

    private static List<object> Expression(int level, Random random)
    {
        List<List<object>> terms = level switch
        {
            1 => [Term(false, random, 12, 99), Term(false, random, 12, 99)],
            2 => [Term(false, random, 10, 99), Term(true, random, 0, 0)],
            3 => random.Next(2) == 0
                ? [Term(false, random, 20, 150), HardTerm(random)]
                : [HardTerm(random), Term(true, random, 0, 0)],
            _ => [Term(false, random, 20, 150), HardTerm(random), Term(true, random, 0, 0)],
        };
        random.Shuffle(System.Runtime.InteropServices.CollectionsMarshal.AsSpan(terms));
        var tokens = new List<object>(terms[0]);
        for (var t = 1; t < terms.Count; t++)
        {
            tokens.Add(random.Next(2) == 0 ? '+' : '−');
            tokens.AddRange(terms[t]);
        }
        return tokens;
    }

    private static MindQuestion MathQuestion(int index, int level, Random random)
    {
        // Results stay at zero or above.
        List<object> tokens;
        do tokens = Expression(level, random); while (Evaluate(tokens) < 0);

        var answer = Evaluate(tokens);
        var naive = LeftToRight(tokens);
        var choices = new List<int> { answer };
        if (naive != answer && naive >= 0) choices.Add(naive);
        // Look-alikes: off by one or two, by ten, and from the higher levels only a small step away.
        int[] steps = level >= 3 ? [1, 2, 10, 3] : [1, 2, 10, 5, 4];
        var guard = 0;
        while (choices.Count < 4 && guard++ < 50)
        {
            var near = answer + (random.Next(2) == 0 ? -1 : 1) * steps[random.Next(steps.Length)];
            if (near >= 0 && !choices.Contains(near)) choices.Add(near);
        }
        for (var k = answer + 1; choices.Count < 4; k++)
        {
            if (!choices.Contains(k)) choices.Add(k);
        }
        random.Shuffle(System.Runtime.InteropServices.CollectionsMarshal.AsSpan(choices));
        var expression = string.Join(' ', tokens.Select(t => t.ToString()));
        return new MindQuestion(index, Math, level,
            new JsonObject { ["expression"] = expression, ["choices"] = new JsonArray([.. choices.Select(c => (JsonNode)c)]) },
            new JsonObject { ["choice"] = choices.IndexOf(answer) }, (6 + 2 * level) * 1000);
    }

    /// <summary>× and ÷ before + and −.</summary>
    public static int Evaluate(IReadOnlyList<object> tokens)
    {
        var sum = 0;
        var sign = 1;
        var term = (int)tokens[0];
        for (var i = 1; i < tokens.Count; i += 2)
        {
            var op = (char)tokens[i];
            var n = (int)tokens[i + 1];
            switch (op)
            {
                case '×': term *= n; break;
                case '÷': term /= n; break;
                default:
                    sum += sign * term;
                    sign = op == '+' ? 1 : -1;
                    term = n;
                    break;
            }
        }
        return sum + sign * term;
    }

    /// <summary>The common mistake: every operation in reading order. Integer division, so it stays a whole number.</summary>
    public static int LeftToRight(IReadOnlyList<object> tokens)
    {
        var value = (int)tokens[0];
        for (var i = 1; i < tokens.Count; i += 2)
        {
            var n = (int)tokens[i + 1];
            value = (char)tokens[i] switch { '+' => value + n, '×' => value * n, '÷' => value / n, _ => value - n };
        }
        return value;
    }

    // -----------------------------------------------------------------------
    // Attention: the words say one figure, the ink says another color.
    // -----------------------------------------------------------------------

    private static JsonObject Figure(string color, string pattern, string shape) =>
        new() { ["color"] = color, ["pattern"] = pattern, ["shape"] = shape };

    private static string Other(string[] from, string not, Random random)
    {
        string pick;
        do pick = from[random.Next(from.Length)]; while (pick == not);
        return pick;
    }

    private static MindQuestion AttentionQuestion(int index, int level, Random random)
    {
        var color = Colors[random.Next(Colors.Length)];
        var pattern = Patterns[random.Next(Patterns.Length)];
        var shape = Shapes[random.Next(Shapes.Length)];
        var ink = Other(Colors, color, random);

        var figures = new List<(string Color, string Pattern, string Shape)> { (color, pattern, shape), (ink, pattern, shape) };
        void Add((string, string, string) f)
        {
            if (!figures.Contains(f)) figures.Add(f);
        }
        if (level >= 2)
        {
            // Every wrong choice is one detail away from the right one.
            Add((color, Other(Patterns, pattern, random), shape));
            Add((color, pattern, Other(Shapes, shape, random)));
        }
        while (figures.Count < 4)
        {
            Add(random.Next(2) == 0
                ? (Colors[random.Next(Colors.Length)], pattern, Other(Shapes, shape, random))
                : (Colors[random.Next(Colors.Length)], Other(Patterns, pattern, random), Shapes[random.Next(Shapes.Length)]));
        }
        random.Shuffle(System.Runtime.InteropServices.CollectionsMarshal.AsSpan(figures));
        return new MindQuestion(index, Attention, level,
            new JsonObject
            {
                ["color"] = color, ["pattern"] = pattern, ["shape"] = shape, ["ink"] = ink,
                ["choices"] = new JsonArray([.. figures.Select(f => (JsonNode)Figure(f.Color, f.Pattern, f.Shape))]),
            },
            new JsonObject { ["choice"] = figures.IndexOf((color, pattern, shape)) }, (8 - level) * 1000);
    }

    // -----------------------------------------------------------------------
    // Memory: colored characters, shown then hidden; pick them back in order and in their colors.
    // -----------------------------------------------------------------------

    public static int ShowMs(int items) => 900 + 500 * items;

    private static MindQuestion MemoryQuestion(int index, int level, Random random)
    {
        var count = 3 + level;
        var chars = Characters.ToCharArray();
        random.Shuffle(chars);
        var items = chars.Take(count).Select(c => (Char: c, Color: Colors[random.Next(Colors.Length)])).ToList();

        // Each character comes in three colors: the shown one and two others, so the color has to be remembered too.
        var options = new List<(char Char, string Color)>();
        foreach (var item in items)
        {
            var colors = Colors.Where(c => c != item.Color).ToArray();
            random.Shuffle(colors);
            options.Add(item);
            options.Add((item.Char, colors[0]));
            options.Add((item.Char, colors[1]));
        }
        // From level 3 look-alike characters (O and 0, 8 and B) join in the shown colors.
        if (level >= 3)
        {
            foreach (var item in items.Where(i => Similar.ContainsKey(i.Char)).Take(level - 1))
            {
                var look = Similar[item.Char];
                var decoy = (look[random.Next(look.Length)], item.Color);
                if (!options.Contains(decoy) && !items.Any(i => i.Char == decoy.Item1)) options.Add(decoy);
            }
        }
        random.Shuffle(System.Runtime.InteropServices.CollectionsMarshal.AsSpan(options));
        static JsonObject Item((char Char, string Color) i) => new() { ["char"] = i.Char.ToString(), ["color"] = i.Color };
        var show = ShowMs(count);
        return new MindQuestion(index, Memory, level,
            new JsonObject
            {
                ["items"] = new JsonArray([.. items.Select(i => (JsonNode)Item(i))]),
                ["options"] = new JsonArray([.. options.Select(o => (JsonNode)Item(o))]),
                ["showMs"] = show,
            },
            new JsonObject { ["picks"] = new JsonArray([.. items.Select(i => (JsonNode)options.IndexOf(i))]) },
            show + 4000 + 1800 * count);
    }

    // -----------------------------------------------------------------------
    // Reflex ("Işık sırası"): 16 red lights; some light up in turn (green, yellow, orange) within two seconds,
    // then all are red again and the same lights are tapped back in order, fast.
    // -----------------------------------------------------------------------

    /// <summary>How many lights the sequence has: 3 at level 1 up to 6 at level 4.</summary>
    public static int SequenceLength(int level) => 2 + level;

    private static MindQuestion ReflexQuestion(int index, int level, Random random)
    {
        var cells = Enumerable.Range(0, ReflexGrid * ReflexGrid).ToArray();
        random.Shuffle(cells);
        var sequence = cells.Take(SequenceLength(level)).ToArray();
        var colors = sequence.Select((_, i) => LightColors[i % LightColors.Length]).ToArray();
        var flash = ReflexShowMs / sequence.Length;
        return new MindQuestion(index, Reflex, level,
            new JsonObject
            {
                ["grid"] = ReflexGrid,
                ["sequence"] = new JsonArray([.. sequence.Select(c => (JsonNode)c)]),
                ["colors"] = new JsonArray([.. colors.Select(c => (JsonNode)c)]),
                ["flashMs"] = flash,
                ["showMs"] = ReflexShowMs,
            },
            new JsonObject { ["picks"] = new JsonArray([.. sequence.Select(c => (JsonNode)c)]) },
            ReflexShowMs + 1500 + 1200 * sequence.Length);
    }

    // -----------------------------------------------------------------------
    // Scoring (docs/ARCHITECTURE.md §3j, Puan)
    // -----------------------------------------------------------------------

    private static int SpeedBonus(double used, double window) => (int)System.Math.Floor(100 * (1 - System.Math.Clamp(used / window, 0, 1)));

    /// <summary>The time to count: the app's own measure, trusted down to <see cref="ClientSlackMs"/> under the server's.</summary>
    public static int CountedMs(int? clientMs, int serverMs) =>
        System.Math.Max(0, System.Math.Clamp(clientMs ?? serverMs, serverMs - ClientSlackMs, serverMs));

    private static int? IntOf(JsonElement answer, string name) =>
        answer.ValueKind == JsonValueKind.Object && answer.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.Number && v.TryGetInt32(out var n)
            ? n : null;

    /// <summary>
    /// Scores an answer that came <paramref name="serverMs"/> after the question was served. Past the limit plus
    /// <see cref="GraceMs"/> it is a timeout (0).
    /// </summary>
    public static MindScore Score(string kind, JsonObject payload, JsonObject solution, int limitMs, JsonElement answer, int? clientMs, int serverMs)
    {
        if (serverMs > limitMs + GraceMs) return new MindScore(0, false);
        var used = CountedMs(clientMs, serverMs);
        switch (kind)
        {
            case Math or Attention:
            {
                var right = IntOf(answer, "choice") is { } choice && choice == (int)solution["choice"]!;
                return right ? new MindScore(100 + SpeedBonus(used, limitMs), true) : new MindScore(0, false);
            }
            case Memory:
            case Reflex when solution.ContainsKey("picks"):
            {
                var expected = solution["picks"]!.AsArray().Select(n => (int)n!).ToArray();
                var picks = answer.ValueKind == JsonValueKind.Object && answer.TryGetProperty("picks", out var p) && p.ValueKind == JsonValueKind.Array
                    ? p.EnumerateArray().Select(e => e.ValueKind == JsonValueKind.Number && e.TryGetInt32(out var n) ? n : -1).ToArray()
                    : [];
                var right = expected.Where((e, i) => i < picks.Length && picks[i] == e).Count();
                if (right == expected.Length && picks.Length == expected.Length)
                {
                    var show = (int)payload["showMs"]!;
                    return new MindScore(100 + SpeedBonus(used - show, limitMs - show), true);
                }
                return new MindScore(60 * right / expected.Length, false);
            }
            default:
            {
                // "Hedefe dokun" (before 2026-11-07): only matches that were running at the update still have it.
                var cell = IntOf(answer, "cell") ?? -1;
                if (cell < 0) return new MindScore(0, false);
                var reaction = IntOf(answer, "reactionMs") ?? -1;
                var delay = (int)payload["delayMs"]!;
                var visible = (int)payload["visibleMs"]!;
                // Before the target, too fast to be a reaction, or faster than the server saw it: early.
                if (reaction < MinReactionMs || serverMs < delay + reaction - 300) return new MindScore(ReflexPenalty, false);
                if (cell != (int)solution["cell"]!) return new MindScore(ReflexPenalty, false);
                if (reaction > visible) return new MindScore(0, false);
                return new MindScore(100 + SpeedBonus(reaction, visible), true);
            }
        }
    }
}
