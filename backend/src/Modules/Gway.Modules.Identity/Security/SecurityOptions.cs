namespace Gway.Modules.Identity;

/// <summary><c>Security</c> configuration (docs/ARCHITECTURE.md §3h). Keys come from the environment.</summary>
public sealed class SecurityOptions
{
    public const string Section = "Security";

    public TwilioOptions Twilio { get; set; } = new();

    public PasskeyOptions Passkeys { get; set; } = new();
}

/// <summary>WebAuthn relying party (docs/ARCHITECTURE.md §3h, Parmak izi).</summary>
public sealed class PasskeyOptions
{
    /// <summary>The site's domain, e.g. <c>gway.app</c>; <c>localhost</c> locally.</summary>
    public string RelyingPartyId { get; set; } = "localhost";

    /// <summary>Exact origins of the app and the panel, e.g. <c>https://gway.app</c>.</summary>
    public string[] Origins { get; set; } = [];
}

public sealed class TwilioOptions
{
    public string AccountSid { get; set; } = "";

    public string AuthToken { get; set; } = "";

    /// <summary>Twilio Verify service (VA…).</summary>
    public string VerifyServiceSid { get; set; } = "";

    /// <summary>Rejects virtual and VoIP numbers with Twilio Lookup (paid per lookup).</summary>
    public bool LookupLineType { get; set; }

    public string VerifyBaseUrl { get; set; } = "https://verify.twilio.com";

    public string LookupBaseUrl { get; set; } = "https://lookups.twilio.com";

    public bool IsConfigured => AccountSid.Length > 0 && AuthToken.Length > 0 && VerifyServiceSid.Length > 0;
}
