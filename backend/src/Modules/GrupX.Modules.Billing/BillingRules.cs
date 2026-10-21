using System.Globalization;
using System.Text.RegularExpressions;
using GrupX.SharedKernel;

namespace GrupX.Modules.Billing;

internal static class BillingErrors
{
    public static readonly Error GroupNotFound = Error.NotFound("billing.group_not_found", "Grup bulunamadı.");
    public static readonly Error Forbidden = Error.Forbidden("billing.forbidden", "Paket işlemlerini yalnızca grup sahibi yapabilir.");
    public static readonly Error GroupSuspended = Error.RuleViolation(
        "billing.group_suspended", "Bu grup askıya alındığı için paket satın alınamaz.");
    public static readonly Error PlanNotForSale = Error.Validation("billing.plan_not_for_sale", "Bu paket şu anda satın alınamıyor.");
    public static readonly Error InvalidPeriod = Error.Validation("billing.invalid_period", "Geçersiz ödeme dönemi.");
    public static readonly Error MarketChanged = Error.Conflict(
        "billing.market_changed", "Bulunduğun ülkeye göre fiyatlar değişti. Lütfen fiyatları yeniden kontrol et.");
    public static readonly Error TermsOutdated = Error.Conflict(
        "billing.terms_outdated", "Mesafeli satış sözleşmesi güncellendi. Lütfen yeni sürümü okuyup onayla.");
    public static readonly Error ProviderUnavailable = Error.Unavailable(
        "billing.provider_unavailable", "Ödeme şu anda alınamıyor. Lütfen daha sonra tekrar dene.");
    public static readonly Error ProviderFailed = Error.Unavailable(
        "billing.provider_error", "Ödeme başlatılamadı. Lütfen biraz sonra tekrar dene.");

    public static Error InvalidDetails(string message) => Error.Validation("billing.invalid_details", message);
}

/// <summary>Invoice details entered at checkout (docs/ARCHITECTURE.md §7, Hukuki ve KVKK).</summary>
public sealed record BillingDetails(string? FirstName, string? LastName, string? Phone, string? Address, string? City, string? Country)
{
    private static readonly Regex PhonePattern = new(@"^\+?[0-9 ()\-]{7,20}$", RegexOptions.CultureInvariant, TimeSpan.FromSeconds(1));

    /// <summary>Trimmed copy, or the first problem as a user-facing error.</summary>
    internal Result<BillingDetails> Validate()
    {
        static string T(string? v) => v?.Trim() ?? "";
        var d = new BillingDetails(T(FirstName), T(LastName), T(Phone), T(Address), T(City), T(Country));

        if (d.FirstName!.Length is < 1 or > 50) return BillingErrors.InvalidDetails("Adını gir (en fazla 50 karakter).");
        if (d.LastName!.Length is < 1 or > 50) return BillingErrors.InvalidDetails("Soyadını gir (en fazla 50 karakter).");
        if (!PhonePattern.IsMatch(d.Phone!)) return BillingErrors.InvalidDetails("Geçerli bir telefon numarası gir.");
        if (d.Address!.Length is < 5 or > 200) return BillingErrors.InvalidDetails("Fatura adresini gir (5–200 karakter).");
        if (d.City!.Length is < 2 or > 50) return BillingErrors.InvalidDetails("Şehri gir.");
        if (d.Country!.Length is < 2 or > 56) return BillingErrors.InvalidDetails("Ülkeyi gir.");
        return d;
    }
}

internal static class Money
{
    /// <summary><c>24900</c> → <c>249.00</c>, the providers' price format.</summary>
    public static string Major(int amountMinor) => (amountMinor / 100m).ToString("0.00", CultureInfo.InvariantCulture);
}
