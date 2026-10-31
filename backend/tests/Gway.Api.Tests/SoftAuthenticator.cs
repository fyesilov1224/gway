using System.Buffers.Binary;
using System.Formats.Cbor;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Gway.Api.Tests;

/// <summary>
/// A software passkey: makes the same attestation and assertion data a browser and a platform authenticator would
/// (ES256, "none" attestation, user verified), so the server's real WebAuthn verification runs in tests.
/// </summary>
internal sealed class SoftAuthenticator : IDisposable
{
    private readonly ECDsa _key = ECDsa.Create(ECCurve.NamedCurves.nistP256);
    private readonly string _origin;
    private readonly byte[] _rpIdHash;
    private uint _counter;
    private byte[] _userHandle = [];

    public SoftAuthenticator(string origin, string rpId = "localhost")
    {
        _origin = origin;
        _rpIdHash = SHA256.HashData(Encoding.UTF8.GetBytes(rpId));
    }

    public byte[] CredentialId { get; } = RandomNumberGenerator.GetBytes(32);

    /// <summary>The browser's answer to <c>navigator.credentials.create</c> for these options.</summary>
    public object Create(string optionsJson)
    {
        using var options = JsonDocument.Parse(optionsJson);
        _userHandle = FromBase64Url(options.RootElement.GetProperty("user").GetProperty("id").GetString()!);
        var clientData = ClientData("webauthn.create", options.RootElement.GetProperty("challenge").GetString()!);

        var cose = new CborWriter(CborConformanceMode.Ctap2Canonical);
        var p = _key.ExportParameters(false);
        cose.WriteStartMap(5);
        cose.WriteInt32(1); cose.WriteInt32(2);    // kty: EC2
        cose.WriteInt32(3); cose.WriteInt32(-7);   // alg: ES256
        cose.WriteInt32(-1); cose.WriteInt32(1);   // crv: P-256
        cose.WriteInt32(-2); cose.WriteByteString(p.Q.X!);
        cose.WriteInt32(-3); cose.WriteByteString(p.Q.Y!);
        cose.WriteEndMap();

        var length = new byte[2];
        BinaryPrimitives.WriteUInt16BigEndian(length, (ushort)CredentialId.Length);
        // Flags: user present, user verified, attested credential data.
        byte[] authData = [.. _rpIdHash, 0x45, .. Counter(), .. new byte[16], .. length, .. CredentialId, .. cose.Encode()];

        var attestation = new CborWriter(CborConformanceMode.Ctap2Canonical);
        attestation.WriteStartMap(3);
        attestation.WriteTextString("fmt"); attestation.WriteTextString("none");
        attestation.WriteTextString("attStmt"); attestation.WriteStartMap(0); attestation.WriteEndMap();
        attestation.WriteTextString("authData"); attestation.WriteByteString(authData);
        attestation.WriteEndMap();

        return new
        {
            id = Base64Url(CredentialId),
            rawId = Base64Url(CredentialId),
            type = "public-key",
            response = new
            {
                clientDataJSON = Base64Url(clientData),
                attestationObject = Base64Url(attestation.Encode()),
                transports = new[] { "internal" },
            },
            clientExtensionResults = new { },
        };
    }

    /// <summary>The browser's answer to <c>navigator.credentials.get</c>: a signature over these options' challenge.</summary>
    public object Get(string optionsJson)
    {
        using var options = JsonDocument.Parse(optionsJson);
        var clientData = ClientData("webauthn.get", options.RootElement.GetProperty("challenge").GetString()!);
        _counter++;
        // Flags: user present, user verified.
        byte[] authData = [.. _rpIdHash, 0x05, .. Counter()];
        var signature = _key.SignData([.. authData, .. SHA256.HashData(clientData)], HashAlgorithmName.SHA256,
            DSASignatureFormat.Rfc3279DerSequence);

        return new
        {
            id = Base64Url(CredentialId),
            rawId = Base64Url(CredentialId),
            type = "public-key",
            response = new
            {
                authenticatorData = Base64Url(authData),
                clientDataJSON = Base64Url(clientData),
                signature = Base64Url(signature),
                userHandle = Base64Url(_userHandle),
            },
            clientExtensionResults = new { },
        };
    }

    private byte[] ClientData(string type, string challenge) =>
        JsonSerializer.SerializeToUtf8Bytes(new Dictionary<string, object>
        {
            ["type"] = type,
            ["challenge"] = challenge,
            ["origin"] = _origin,
            ["crossOrigin"] = false,
        });

    private byte[] Counter()
    {
        var bytes = new byte[4];
        BinaryPrimitives.WriteUInt32BigEndian(bytes, _counter);
        return bytes;
    }

    private static string Base64Url(byte[] bytes) => Convert.ToBase64String(bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');

    private static byte[] FromBase64Url(string s)
    {
        s = s.Replace('-', '+').Replace('_', '/');
        return Convert.FromBase64String(s.PadRight(s.Length + ((4 - (s.Length % 4)) % 4), '='));
    }

    public void Dispose() => _key.Dispose();
}
