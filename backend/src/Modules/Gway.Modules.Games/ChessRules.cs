using System.Text.RegularExpressions;
using Chess;

namespace Gway.Modules.Games;

/// <summary>A time control from the catalog (docs/ARCHITECTURE.md §3i, Süre türleri).</summary>
internal readonly record struct TimeControl(int BaseSeconds, int IncrementSeconds)
{
    public static readonly TimeControl[] Catalog =
    [
        new(60, 0), new(120, 1),
        new(180, 0), new(180, 2), new(300, 0), new(300, 3),
        new(600, 0), new(600, 5), new(900, 10),
    ];

    public bool IsValid => Catalog.Contains(this);

    /// <summary>Estimated length base + 40 × increment: under 180 s bullet, under 480 s blitz, otherwise rapid.</summary>
    public string Category => (BaseSeconds + 40 * IncrementSeconds) switch
    {
        < 180 => "bullet",
        < 480 => "blitz",
        _ => "rapid",
    };
}

/// <summary>What a game ended with; <see cref="Result"/> is null for an aborted game.</summary>
internal readonly record struct Outcome(string? Result, string Termination)
{
    public static Outcome Aborted => new(null, "aborted");

    public static Outcome Win(string color, string termination) => new(color, termination);

    public static Outcome Draw(string termination) => new("draw", termination);
}

/// <summary>The result of playing one move on the game so far.</summary>
internal sealed record PlayedMove(string Uci, string San, string Fen, Outcome? End);

/// <summary>Chess rules on top of Gera.Chess (MIT): legality, game end, Elo. No database here.</summary>
internal static partial class ChessRules
{
    public const string White = "white";
    public const string Black = "black";

    /// <summary>Each side's first move must come within this, or the game is aborted.</summary>
    public static readonly TimeSpan FirstMoveWindow = TimeSpan.FromSeconds(30);

    public const int StartRating = 1200;
    public const int MinRating = 100;

    [GeneratedRegex("^[a-h][1-8][a-h][1-8][qrbn]?$")]
    private static partial Regex UciFormat();

    public static string Opposite(string color) => color == White ? Black : White;

    /// <summary>The side to move after <paramref name="plies"/> half-moves.</summary>
    public static string ToMove(int plies) => plies % 2 == 0 ? White : Black;

    /// <summary>
    /// Replays <paramref name="moves"/> (all legal, the server wrote them) and plays <paramref name="uci"/>.
    /// Null when the move is malformed or illegal. A pawn reaching the last rank without a piece becomes a queen.
    /// </summary>
    public static PlayedMove? Play(IReadOnlyList<string> moves, string uci)
    {
        if (!UciFormat().IsMatch(uci)) return null;
        var board = Replay(moves);
        if (board.IsEndGame) return null;

        var promotion = uci.Length == 5 ? uci[4] : 'q';
        board.OnPromotePawn += (_, e) => e.PromotionResult = promotion switch
        {
            'r' => PromotionType.ToRook,
            'b' => PromotionType.ToBishop,
            'n' => PromotionType.ToKnight,
            _ => PromotionType.ToQueen,
        };
        var move = new Move(uci[..2], uci[2..4]);
        if (!board.IsValidMove(move) || !board.Move(move)) return null;

        var played = board.ExecutedMoves[^1];
        // A promotion is always stored with its piece, so a replay promotes the same way.
        var stored = played.IsPromotion && uci.Length == 4 ? uci + 'q' : uci;
        return new PlayedMove(stored, played.San ?? stored, board.ToFen(), EndOf(board));
    }

    private static ChessBoard Replay(IReadOnlyList<string> moves)
    {
        var board = new ChessBoard { AutoEndgameRules = AutoEndgameRules.All };
        foreach (var m in moves)
        {
            var promotion = m.Length == 5 ? m[4] : 'q';
            void Promote(object? sender, PromotionEventArgs e) => e.PromotionResult = promotion switch
            {
                'r' => PromotionType.ToRook,
                'b' => PromotionType.ToBishop,
                'n' => PromotionType.ToKnight,
                _ => PromotionType.ToQueen,
            };
            board.OnPromotePawn += Promote;
            if (!board.Move(new Move(m[..2], m[2..4]))) throw new InvalidOperationException($"Stored move {m} does not replay.");
            board.OnPromotePawn -= Promote;
        }
        return board;
    }

    private static Outcome? EndOf(ChessBoard board)
    {
        if (!board.IsEndGame || board.EndGame is not { } end) return null;
        return end.EndgameType switch
        {
            EndgameType.Checkmate => Outcome.Win(end.WonSide == PieceColor.White ? White : Black, "checkmate"),
            EndgameType.Stalemate => Outcome.Draw("stalemate"),
            EndgameType.InsufficientMaterial => Outcome.Draw("insufficient"),
            EndgameType.FiftyMoveRule => Outcome.Draw("fifty_moves"),
            EndgameType.Repetition => Outcome.Draw("repetition"),
            _ => null,
        };
    }

    /// <summary>
    /// Whether <paramref name="color"/> could still mate in the position: anything beyond a bare king
    /// or a king with a single knight or bishop. A flag against such a side is a draw.
    /// </summary>
    public static bool CanMate(string fen, string color)
    {
        var placement = fen.Split(' ')[0];
        var pieces = placement.Where(char.IsLetter).Where(c => color == White ? char.IsUpper(c) : char.IsLower(c))
            .Select(char.ToLowerInvariant).Where(c => c != 'k').ToList();
        return !(pieces.Count == 0 || (pieces.Count == 1 && pieces[0] is 'n' or 'b'));
    }

    /// <summary>The player's K-factor: 40 for the first 30 rated games, 20 under 2400, then 10.</summary>
    public static int KFactor(int rating, int games) => games < 30 ? 40 : rating < 2400 ? 20 : 10;

    /// <summary>Rating changes for both sides; <paramref name="whiteScore"/> is 1, 0.5 or 0. Ratings never go under 100.</summary>
    public static (int White, int Black) EloDeltas(int whiteRating, int whiteGames, int blackRating, int blackGames, double whiteScore)
    {
        var expected = 1 / (1 + Math.Pow(10, (blackRating - whiteRating) / 400.0));
        var white = (int)Math.Round(KFactor(whiteRating, whiteGames) * (whiteScore - expected), MidpointRounding.AwayFromZero);
        var black = (int)Math.Round(KFactor(blackRating, blackGames) * ((1 - whiteScore) - (1 - expected)), MidpointRounding.AwayFromZero);
        return (Math.Max(MinRating, whiteRating + white) - whiteRating, Math.Max(MinRating, blackRating + black) - blackRating);
    }
}
