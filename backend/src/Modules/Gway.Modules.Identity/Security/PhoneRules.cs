using Gway.SharedKernel;
using PhoneNumbers;

namespace Gway.Modules.Identity;

/// <summary>A mobile number in E.164 and the country it belongs to (libphonenumber metadata).</summary>
internal sealed record ParsedPhone(string E164, string Country);

internal static class PhoneRules
{
    private static readonly PhoneNumberUtil Util = PhoneNumberUtil.GetInstance();

    private static readonly Error Invalid = Error.Validation("security.phone_invalid", "Geçerli bir cep telefonu numarası gir.");

    private static readonly Error NotMobile = Error.Validation("security.phone_not_mobile", "Yalnızca cep telefonu numarasıyla doğrulama yapılabilir.");

    /// <param name="defaultCountry">Used when the input has no country code.</param>
    public static Result<ParsedPhone> Parse(string? input, string defaultCountry)
    {
        if (string.IsNullOrWhiteSpace(input) || input.Length > 32) return Invalid;
        PhoneNumber number;
        try
        {
            number = Util.Parse(input, defaultCountry);
        }
        catch (NumberParseException)
        {
            return Invalid;
        }
        if (!Util.IsValidNumber(number)) return Invalid;
        if (Util.GetNumberType(number) is not (PhoneNumberType.MOBILE or PhoneNumberType.FIXED_LINE_OR_MOBILE)) return NotMobile;

        return new ParsedPhone(Util.Format(number, PhoneNumberFormat.E164), Util.GetRegionCodeForNumber(number));
    }

    /// <summary>The calling code and the last two digits, e.g. <c>+90 ••• ••• •• 34</c>.</summary>
    public static string Mask(string e164)
    {
        var code = Util.Parse(e164, null).CountryCode.ToString(System.Globalization.CultureInfo.InvariantCulture);
        return $"+{code} ••• ••• •• {e164[^2..]}";
    }

    /// <summary>The dialling code of a country, for the locked prefix in the app (e.g. TR → 90).</summary>
    public static int CallingCode(string country) => Util.GetCountryCodeForRegion(country);
}
