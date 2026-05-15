---
name: docx-official
description: Generating Word documents programmatically with docx library in Node.js. Use when generating .docx reports, contracts, invoices, or any structured Word document from data.
---

# Generating Word Documents with docx

## Installation

```bash
npm install docx
# or
pnpm add docx
```

## Basic Document

```typescript
import {
  Document, Packer, Paragraph, TextRun,
  HeadingLevel, AlignmentType, BorderStyle,
} from 'docx'

async function generateReport(data: ReportData): Promise<Buffer> {
  const doc = new Document({
    creator:     'Antigravity HQ',
    title:       data.title,
    description: data.description,
    styles: {
      default: {
        document: {
          run: {
            font:     'Calibri',
            size:     24,  // half-points (24 = 12pt)
            color:    '333333',
          },
        },
      },
    },
    sections: [
      {
        properties: {},
        children: [
          new Paragraph({
            text:    data.title,
            heading: HeadingLevel.HEADING_1,
            spacing: { after: 200 },
          }),
          new Paragraph({
            children: [
              new TextRun({ text: 'Generated: ', bold: true }),
              new TextRun({ text: new Date().toLocaleDateString() }),
            ],
            spacing: { after: 400 },
          }),
          ...data.paragraphs.map(text =>
            new Paragraph({
              text,
              spacing: { after: 160 },
              alignment: AlignmentType.JUSTIFIED,
            })
          ),
        ],
      },
    ],
  })

  return Packer.toBuffer(doc)
}
```

## Tables

```typescript
import { Table, TableRow, TableCell, WidthType, ShadingType } from 'docx'

function createDataTable(headers: string[], rows: string[][]): Table {
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      // Header row
      new TableRow({
        tableHeader: true,
        children: headers.map(header =>
          new TableCell({
            shading: { type: ShadingType.SOLID, color: '2563EB' },
            children: [
              new Paragraph({
                children: [new TextRun({ text: header, bold: true, color: 'FFFFFF' })],
              }),
            ],
          })
        ),
      }),
      // Data rows
      ...rows.map((row, rowIndex) =>
        new TableRow({
          children: row.map(cell =>
            new TableCell({
              shading: rowIndex % 2 === 0
                ? { type: ShadingType.SOLID, color: 'F8FAFC' }
                : undefined,
              children: [
                new Paragraph({ text: cell }),
              ],
            })
          ),
        })
      ),
    ],
  })
}
```

## Headers & Footers

```typescript
import { Header, Footer, PageNumber, NumberFormat } from 'docx'

const doc = new Document({
  sections: [
    {
      properties: {
        page: {
          size:   { width: 12240, height: 15840 }, // Letter size in twips
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
        },
        pageNumberStart: 1,
        pageNumberFormatType: NumberFormat.DECIMAL,
      },
      headers: {
        default: new Header({
          children: [
            new Paragraph({
              children: [
                new TextRun({ text: 'Antigravity HQ — Confidential', color: '6B7280', size: 18 }),
              ],
              border: {
                bottom: { style: BorderStyle.SINGLE, size: 1, color: 'E5E7EB' },
              },
            }),
          ],
        }),
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              children: [
                new TextRun({ text: 'Page ' }),
                new TextRun({ children: [PageNumber.CURRENT] }),
                new TextRun({ text: ' of ' }),
                new TextRun({ children: [PageNumber.TOTAL_PAGES] }),
              ],
              alignment: AlignmentType.CENTER,
            }),
          ],
        }),
      },
      children: [/* document content */],
    },
  ],
})
```

## Lists

```typescript
import { LevelFormat } from 'docx'

const doc = new Document({
  numbering: {
    config: [
      {
        reference: 'bullet-list',
        levels: [
          {
            level:  0,
            format: LevelFormat.BULLET,
            text:   '•',
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 720, hanging: 360 } } },
          },
        ],
      },
      {
        reference: 'numbered-list',
        levels: [
          {
            level:  0,
            format: LevelFormat.DECIMAL,
            text:   '%1.',
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 720, hanging: 360 } } },
          },
        ],
      },
    ],
  },
  sections: [
    {
      children: [
        ...[
          'First item',
          'Second item',
          'Third item',
        ].map(text =>
          new Paragraph({
            text,
            numbering: { reference: 'bullet-list', level: 0 },
          })
        ),
      ],
    },
  ],
})
```

## Images

```typescript
import { ImageRun } from 'docx'
import * as fs from 'fs'

const imageBuffer = fs.readFileSync('./logo.png')

const paragraph = new Paragraph({
  children: [
    new ImageRun({
      data:          imageBuffer,
      transformation: {
        width:  150,
        height: 50,
      },
    }),
  ],
})
```

## NestJS Service

```typescript
// documents/documents.service.ts
@Injectable()
export class DocumentsService {
  async generateInvoice(invoice: Invoice): Promise<Buffer> {
    const doc = new Document({
      sections: [
        {
          children: [
            new Paragraph({ text: 'INVOICE', heading: HeadingLevel.HEADING_1 }),
            new Paragraph({ text: `Invoice #${invoice.number}` }),
            new Paragraph({ text: `Date: ${invoice.date.toLocaleDateString()}` }),
            new Paragraph({ text: '' }),
            createDataTable(
              ['Description', 'Qty', 'Unit Price', 'Total'],
              invoice.items.map(item => [
                item.description,
                String(item.quantity),
                `$${item.unitPrice.toFixed(2)}`,
                `$${(item.quantity * item.unitPrice).toFixed(2)}`,
              ])
            ),
            new Paragraph({ text: '' }),
            new Paragraph({
              children: [
                new TextRun({ text: 'Total: ', bold: true }),
                new TextRun({ text: `$${invoice.total.toFixed(2)}`, bold: true, size: 28 }),
              ],
              alignment: AlignmentType.RIGHT,
            }),
          ],
        },
      ],
    })

    return Packer.toBuffer(doc)
  }
}

// documents/documents.controller.ts
@Get('invoice/:id/download')
@UseGuards(JwtAuthGuard)
async downloadInvoice(
  @Param('id') id: string,
  @Res() res: Response,
) {
  const invoice = await this.invoiceService.findOneOrFail(id)
  const buffer  = await this.documentsService.generateInvoice(invoice)

  res.set({
    'Content-Type':        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'Content-Disposition': `attachment; filename="invoice-${invoice.number}.docx"`,
    'Content-Length':      buffer.length,
  })

  res.end(buffer)
}
```

## Forbidden Patterns

- Never use `Packer.toBuffer` synchronously and block the event loop on large documents — use async streaming for huge files
- Never construct file paths from user input without sanitization
- Never trust user-provided content without sanitizing HTML/special characters
- Never include sensitive data (passwords, secrets) in generated documents
