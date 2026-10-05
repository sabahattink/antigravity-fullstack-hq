# Full Stack HQ — Türkçe özet

[English README](README.md) · [SSS (İngilizce)](docs/FAQ.md) · [Karşılaştırma (İngilizce)](docs/COMPARISON.md)

Full Stack HQ, yapay zekâ kodlama ajanları için açık kaynaklı (MIT) ve
**izin öncelikli** bir mühendislik yapılandırma kitidir. Ortak kurallar,
10 uzman ajan, 28 Agent Skill ve 10 workflow tek bir kaynakta tutulur. Bu
kaynak, her aracın kendi formatına dönüştürülür:

- **Claude Code:** `CLAUDE.md` ve plugin
- **OpenAI Codex:** `AGENTS.md` ve TOML ajanlar
- **Google Antigravity IDE:** `GEMINI.md` ve workflow'lar
- **Cursor, GitHub Copilot ve Gemini CLI:** projenin `AGENTS.md` dosyası
  üzerinden

## Temel kural

Ajan önce projeyi inceler ve bir plan önerir. Dosya değiştirmeye ancak
mesajınızda şu ifadelerden biri birebir geçtiğinde başlar:

```text
PLAN APPROVED
IMPLEMENTATION APPROVED
PROCEED
DO IT
```

"Olur" ya da "tamam" gibi belirsiz cevaplar onay sayılmaz. Bu kurallar ajana
verilen talimatlardır, bir sandbox değildir; araçların izin ayarları geçerli
olmaya devam eder.

## Kurulum

### Claude Code: iki komut, klonlamadan

Claude Code içinde:

```text
/plugin marketplace add sabahattink/antigravity-fullstack-hq
/plugin install full-stack-hq@full-stack-hq
```

Yeni bir oturum açın. Kurallar oturum başında yüklenir; workflow'lar
`/full-stack-hq:plan` gibi komutlar olarak gelir.

### Tüm araçlar: tek satır, önce önizleme

`--dry-run` hiçbir dosyaya yazmadan neyin kurulacağını gösterir:

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/bootstrap.sh | bash -s -- --dry-run
```

```powershell
# Windows PowerShell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/bootstrap.ps1))) -DryRun
```

Gerçek kurulum için `--dry-run` / `-DryRun` seçeneğini kaldırın. Yalnızca bir
araç için `--only-codex`, `--only-claude` veya `--only-antigravity`
ekleyebilirsiniz; değiştirilen dosyaların yedeğini almak için `--backup`
kullanın.

### Projeniz: bütün ekip için ortak kurallar

Kuralları ev dizininiz yerine bir repoya kurun; repoyu açan herkes, hangi
ajanı kullanırsa kullansın aynı kuralları alır:

```bash
bash install.sh --project ../projeniz
```

```powershell
.\install.ps1 -Project ..\projeniz
```

Kurallar `AGENTS.md` dosyasına yazılır. `CLAUDE.md` ve `GEMINI.md` dosyalarına
yalnızca tek satırlık bir içe aktarma eklenir. Yükleyici sadece
`<!-- full-stack-hq:start -->` ile `<!-- full-stack-hq:end -->` arasındaki
bloğu yönetir; dosyalarda zaten olan içerik korunur. Güncellemek için komutu
tekrar çalıştırın. Kaldırmak için `--uninstall` / `-Uninstall` ekleyin;
dosyalar eski haline döner.

## Neler var?

| Bölüm | İçerik |
|---|---|
| Ajanlar | Mimar, frontend, backend, veritabanı, kod inceleme, test, güvenlik, DevOps, performans ve dokümantasyon uzmanları |
| Skill'ler | Next.js, React, TypeScript, Tailwind, NestJS, Prisma, API tasarımı, kimlik doğrulama, güvenlik, test, hata ayıklama, Docker, GitHub Actions, dağıtım ve doküman skill'leri |
| Workflow'lar | plan, brainstorm, create, debug, enhance, test, status, preview, orchestrate, ui-ux-pro-max |

## Doğrulama

Her pull request'te Windows ve Ubuntu üzerinde şunlar çalışır:

- Kaynak dosya ve adaptör doğrulayıcıları
- Yalıtılmış dizinlerde kurulum testleri
- Proje modu testleri: mevcut içerik korunuyor mu, tekrar çalıştırma bir şey
  değiştiriyor mu, kaldırma dosyaları eski haline döndürüyor mu
- Claude Code plugin manifest kontrolü

Yerelde çalıştırmak için:

```bash
bash scripts/validate.sh
bash scripts/smoke-test.sh
```

## Katkı ve geri bildirim

Kurulum sonucunuzu paylaşmak en değerli katkıdır:
[kurulum geri bildirim formu](https://github.com/sabahattink/antigravity-fullstack-hq/issues/new?template=installation_feedback.md).
Ayrıntılı belgeler İngilizcedir:
[kurulum rehberi](docs/SETUP.md), [özelleştirme rehberi](docs/CUSTOMIZATION.md),
[katkı rehberi](docs/CONTRIBUTING.md).

Lisans: MIT. Geliştiren: [Sabahattin Kalkan](https://github.com/sabahattink).
