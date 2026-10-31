using System.Buffers.Binary;
using System.Security.Cryptography;
using System.Text;

namespace Gway.Modules.Identity;

/// <summary>RFC 6238 authenticator codes: HMAC-SHA1, 30-second steps, 6 digits (docs/ARCHITECTURE.md §3h).</summary>
internal static class Totp
{
    public const int SecretLength = 20;
    private const int StepSeconds = 30;
    private const string Base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

    public static byte[] NewSecret() => RandomNumberGenerator.GetBytes(SecretLength);

    public static long StepAt(DateTimeOffset time) => time.ToUnixTimeSeconds() / StepSeconds;

    public static string Code(byte[] secret, long step)
    {
        Span<byte> counter = stackalloc byte[8];
        BinaryPrimitives.WriteInt64BigEndian(counter, step);
        Span<byte> hash = stackalloc byte[20];
#pragma warning disable CA5350 // RFC 6238 authenticator apps use HMAC-SHA1
        HMACSHA1.HashData(secret, counter, hash);
#pragma warning restore CA5350
        var offset = hash[^1] & 0x0F;
        var binary = BinaryPrimitives.ReadInt32BigEndian(hash[offset..]) & 0x7FFFFFFF;
        return (binary % 1_000_000).ToString("D6", System.Globalization.CultureInfo.InvariantCulture);
    }

    /// <summary>
    /// The step [code] matches within one step of [now], or null. A step at or before [lastStep] never matches,
    /// so a code cannot be replayed.
    /// </summary>
    public static long? Verify(byte[] secret, string? code, DateTimeOffset now, long? lastStep)
    {
        if (code is not { Length: 6 } || !code.All(char.IsAsciiDigit)) return null;
        var current = StepAt(now);
        var given = Encoding.ASCII.GetBytes(code);
        for (var step = current - 1; step <= current + 1; step++)
        {
            if (lastStep is { } last && step <= last) continue;
            if (CryptographicOperations.FixedTimeEquals(Encoding.ASCII.GetBytes(Code(secret, step)), given)) return step;
        }
        return null;
    }

    public static string Base32(byte[] data)
    {
        var sb = new StringBuilder((data.Length * 8 + 4) / 5);
        int buffer = 0, bits = 0;
        foreach (var b in data)
        {
            buffer = (buffer << 8) | b;
            bits += 8;
            while (bits >= 5)
            {
                sb.Append(Base32Alphabet[(buffer >> (bits - 5)) & 31]);
                bits -= 5;
            }
        }
        if (bits > 0) sb.Append(Base32Alphabet[(buffer << (5 - bits)) & 31]);
        return sb.ToString();
    }

    public static string SetupUri(string base32Secret) =>
        $"otpauth://totp/GWAY?secret={base32Secret}&issuer=GWAY&algorithm=SHA1&digits=6&period={StepSeconds}";
}
