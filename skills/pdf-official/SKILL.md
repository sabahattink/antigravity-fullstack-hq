---
name: pdf-official
description: Generating PDFs with pdfkit or puppeteer in Node.js. Use when generating PDF reports, invoices, certificates, or any printable document from data or HTML templates.
---

# PDF Generation

## Option A — PDFKit (Programmatic)

Best for: invoices, receipts, structured data documents with precise control.

```bash
npm install pdfkit
npm install -D @types/pdfkit
```

```typescript
// lib/pdf/invoice-pdf.ts
import PDFDocument from 'pdfkit'
import { PassThrough } from 'stream'

export async function generateInvoicePdf(invoice: Invoice): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc    = new PDFDocument({ margin: 50, size: 'A4' })
    const chunks: Buffer[] = []

    doc.on('data',  chunk => chunks.push(chunk))
    doc.on('end',   ()    => resolve(Buffer.concat(chunks)))
    doc.on('error', reject)

    // ─── Header ──────────────────────────────────────────────
    doc
      .fillColor('#2563EB')
      .fontSize(28)
      .font('Helvetica-Bold')
      .text('INVOICE', 50, 50)

    doc
      .fillColor('#6B7280')
      .fontSize(10)
      .font('Helvetica')
      .text(`Invoice #${invoice.number}`, 50, 90)
      .text(`Date: ${invoice.date.toLocaleDateString('en-US')}`, 50, 105)
      .text(`Due: ${invoice.dueDate.toLocaleDateString('en-US')}`, 50, 120)

    // Company info on the right
    doc
      .fillColor('#111827')
      .fontSize(10)
      .text('Antigravity HQ', 400, 50, { align: 'right' })
      .text('123 Tech Street', 400, 65, { align: 'right' })
      .text('contact@antigravity.dev', 400, 80, { align: 'right' })

    // ─── Divider ─────────────────────────────────────────────
    doc
      .strokeColor('#E5E7EB')
      .lineWidth(1)
      .moveTo(50, 145)
      .lineTo(545, 145)
      .stroke()

    // ─── Bill To ─────────────────────────────────────────────
    doc
      .fillColor('#374151')
      .fontSize(9)
      .font('Helvetica-Bold')
      .text('BILL TO', 50, 160)
      .font('Helvetica')
      .text(invoice.client.name,    50, 175)
      .text(invoice.client.address, 50, 190)
      .text(invoice.client.email,   50, 205)

    // ─── Table Header ─────────────────────────────────────────
    const tableTop = 250
    doc
      .fillColor('#2563EB')
      .rect(50, tableTop, 495, 22)
      .fill()
      .fillColor('#FFFFFF')
      .font('Helvetica-Bold')
      .fontSize(9)
      .text('Description', 60,  tableTop + 7)
      .text('Qty',         330, tableTop + 7, { width: 50, align: 'right' })
      .text('Unit Price',  385, tableTop + 7, { width: 70, align: 'right' })
      .text('Amount',      460, tableTop + 7, { width: 80, align: 'right' })

    // ─── Table Rows ───────────────────────────────────────────
    let y = tableTop + 30
    invoice.items.forEach((item, i) => {
      if (i % 2 === 0) {
        doc.fillColor('#F8FAFC').rect(50, y - 4, 495, 22).fill()
      }
      doc
        .fillColor('#374151')
        .font('Helvetica')
        .fontSize(9)
        .text(item.description, 60,  y)
        .text(String(item.quantity), 330, y, { width: 50, align: 'right' })
        .text(`$${item.unitPrice.toFixed(2)}`, 385, y, { width: 70, align: 'right' })
        .text(`$${(item.quantity * item.unitPrice).toFixed(2)}`, 460, y, { width: 80, align: 'right' })

      y += 22
    })

    // ─── Total ────────────────────────────────────────────────
    doc
      .strokeColor('#E5E7EB')
      .lineWidth(1)
      .moveTo(380, y + 5)
      .lineTo(545, y + 5)
      .stroke()

    doc
      .fillColor('#111827')
      .font('Helvetica-Bold')
      .fontSize(11)
      .text('Total:', 380, y + 15)
      .text(`$${invoice.total.toFixed(2)}`, 460, y + 15, { width: 80, align: 'right' })

    doc.end()
  })
}
```

## Option B — Puppeteer (HTML → PDF)

Best for: complex layouts, charts, styled reports that are easier to build in HTML/CSS.

```bash
npm install puppeteer
# For production Docker: use puppeteer-core + system Chrome
npm install puppeteer-core
```

```typescript
// lib/pdf/html-pdf.ts
import puppeteer from 'puppeteer'

export async function htmlToPdf(html: string, options?: {
  format?: 'A4' | 'Letter'
  landscape?: boolean
  margin?: { top: string; right: string; bottom: string; left: string }
}): Promise<Buffer> {
  const browser = await puppeteer.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',  // required in Docker
    ],
  })

  try {
    const page = await browser.newPage()

    await page.setContent(html, { waitUntil: 'networkidle0' })

    const buffer = await page.pdf({
      format:    options?.format ?? 'A4',
      landscape: options?.landscape ?? false,
      margin:    options?.margin ?? { top: '20mm', right: '15mm', bottom: '20mm', left: '15mm' },
      printBackground: true,
    })

    return Buffer.from(buffer)
  } finally {
    await browser.close()
  }
}

// HTML template for a report
function buildReportHtml(data: ReportData): string {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8" />
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Helvetica', sans-serif; color: #111; font-size: 12px; }
        .header { background: #2563EB; color: white; padding: 20px 30px; }
        .header h1 { font-size: 24px; }
        .content { padding: 30px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #F1F5F9; text-align: left; padding: 8px 12px; font-weight: 600; font-size: 11px; text-transform: uppercase; color: #64748B; }
        td { padding: 8px 12px; border-bottom: 1px solid #E2E8F0; }
        tr:hover td { background: #F8FAFC; }
        .total { font-size: 16px; font-weight: 700; text-align: right; padding: 16px 0; }
        @media print {
          .no-print { display: none; }
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>${data.title}</h1>
        <p>Generated: ${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
      </div>
      <div class="content">
        <table>
          <thead>
            <tr>${data.columns.map(c => `<th>${c}</th>`).join('')}</tr>
          </thead>
          <tbody>
            ${data.rows.map(row => `
              <tr>${row.map(cell => `<td>${cell}</td>`).join('')}</tr>
            `).join('')}
          </tbody>
        </table>
        <div class="total">Total: ${data.total}</div>
      </div>
    </body>
    </html>
  `
}
```

## NestJS Service + Controller

```typescript
// reports/reports.service.ts
@Injectable()
export class ReportsService {
  async generateInvoicePdf(invoiceId: string): Promise<Buffer> {
    const invoice = await this.invoiceService.findOneOrFail(invoiceId)
    return generateInvoicePdf(invoice)
  }

  async generateHtmlReport(data: ReportData): Promise<Buffer> {
    const html = buildReportHtml(data)
    return htmlToPdf(html, { format: 'A4' })
  }
}

// reports/reports.controller.ts
@Get(':id/pdf')
@UseGuards(JwtAuthGuard)
async downloadPdf(
  @Param('id') id: string,
  @Res() res: Response,
) {
  const buffer = await this.reportsService.generateInvoicePdf(id)

  res.set({
    'Content-Type':        'application/pdf',
    'Content-Disposition': `attachment; filename="invoice-${id}.pdf"`,
    'Content-Length':      buffer.length,
  })

  res.end(buffer)
}

// Stream large PDFs instead of buffering
@Get(':id/pdf/stream')
async streamPdf(@Param('id') id: string, @Res() res: Response) {
  res.setHeader('Content-Type', 'application/pdf')
  res.setHeader('Content-Disposition', `attachment; filename="report-${id}.pdf"`)

  const doc = new PDFDocument()
  doc.pipe(res)
  // ... build doc
  doc.end()
}
```

## Puppeteer in Docker

```dockerfile
# Install Chrome dependencies for Puppeteer in Alpine
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
```

## Forbidden Patterns

- Never call `puppeteer.launch()` per request in high-traffic scenarios — pool browser instances
- Never pass unsanitized user input directly into HTML templates — risk of injection
- Never load external resources in Puppeteer on a server — use `--disable-extensions` and local assets
- Never stream to a closed response — always handle the `res.writableEnded` case
