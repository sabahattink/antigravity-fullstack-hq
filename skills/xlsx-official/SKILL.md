---
name: xlsx-official
description: Generating Excel files with xlsx/exceljs in Node.js. Use when generating .xlsx reports, data exports, dashboards, or spreadsheets from database data.
---

# Excel Generation

## Option A — ExcelJS (Feature-Rich)

```bash
npm install exceljs
npm install -D @types/node
```

```typescript
// lib/excel/report.excel.ts
import ExcelJS from 'exceljs'

export async function generateExcelReport(data: ReportData): Promise<Buffer> {
  const workbook  = new ExcelJS.Workbook()
  workbook.creator    = 'Antigravity HQ'
  workbook.lastModifiedBy = 'system'
  workbook.created    = new Date()
  workbook.modified   = new Date()

  const sheet = workbook.addWorksheet('Report', {
    pageSetup: {
      paperSize:   9,   // A4
      orientation: 'landscape',
      fitToPage:   true,
    },
    views: [{ state: 'frozen', xSplit: 0, ySplit: 1 }],  // freeze header row
  })

  // ─── Column Definitions ───────────────────────────────────
  sheet.columns = data.columns.map(col => ({
    header:  col.header,
    key:     col.key,
    width:   col.width ?? 20,
    style: {
      alignment: { horizontal: col.align ?? 'left', wrapText: false },
      numFmt:    col.format,  // e.g. '#,##0.00', 'yyyy-mm-dd'
    },
  }))

  // ─── Style the Header Row ─────────────────────────────────
  const headerRow = sheet.getRow(1)
  headerRow.eachCell(cell => {
    cell.fill = {
      type:    'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF2563EB' },
    }
    cell.font = {
      name:  'Calibri',
      size:  11,
      bold:  true,
      color: { argb: 'FFFFFFFF' },
    }
    cell.border = {
      bottom: { style: 'medium', color: { argb: 'FF1D4ED8' } },
    }
  })
  headerRow.height = 24

  // ─── Add Data Rows ────────────────────────────────────────
  data.rows.forEach((row, index) => {
    const excelRow = sheet.addRow(row)
    excelRow.height = 18

    // Alternating row colors
    if (index % 2 === 0) {
      excelRow.eachCell(cell => {
        cell.fill = {
          type:    'pattern',
          pattern: 'solid',
          fgColor: { argb: 'FFF8FAFC' },
        }
      })
    }

    excelRow.eachCell(cell => {
      cell.font   = { name: 'Calibri', size: 10 }
      cell.border = {
        bottom: { style: 'thin', color: { argb: 'FFE5E7EB' } },
      }
    })
  })

  // ─── Summary Row ──────────────────────────────────────────
  const summaryRow = sheet.addRow(data.summary)
  summaryRow.eachCell(cell => {
    cell.font = { name: 'Calibri', size: 10, bold: true }
    cell.fill = {
      type:    'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFEFF6FF' },
    }
    cell.border = {
      top:    { style: 'medium', color: { argb: 'FF2563EB' } },
      bottom: { style: 'medium', color: { argb: 'FF2563EB' } },
    }
  })

  // ─── Auto-filter ──────────────────────────────────────────
  sheet.autoFilter = {
    from: { row: 1, column: 1 },
    to:   { row: 1, column: data.columns.length },
  }

  // ─── Return Buffer ────────────────────────────────────────
  return workbook.xlsx.writeBuffer() as Promise<Buffer>
}
```

## Multiple Sheets

```typescript
async function generateMultiSheetReport(report: MultiSheetReport): Promise<Buffer> {
  const workbook = new ExcelJS.Workbook()

  // Summary sheet
  const summarySheet = workbook.addWorksheet('Summary')
  addSummarySheet(summarySheet, report.summary)

  // Data sheets
  for (const section of report.sections) {
    const sheet = workbook.addWorksheet(section.name.substring(0, 31)) // Excel 31-char limit
    addDataSheet(sheet, section.columns, section.rows)
  }

  // Charts sheet (using data from other sheets)
  const chartSheet = workbook.addWorksheet('Charts')
  addChart(workbook, chartSheet, report)

  return workbook.xlsx.writeBuffer() as Promise<Buffer>
}
```

## Charts in ExcelJS

```typescript
function addChart(workbook: ExcelJS.Workbook, sheet: ExcelJS.Worksheet, report: Report) {
  // ExcelJS doesn't support charts directly — use chartjs-to-image or
  // embed a pre-generated chart image

  // Generate chart as PNG buffer (using chartjs-node-canvas)
  const chartImage = generateChartPng(report.chartData)

  const imageId = workbook.addImage({
    buffer:    chartImage,
    extension: 'png',
  })

  sheet.addImage(imageId, {
    tl:        { col: 0, row: 0 },
    ext:       { width: 800, height: 400 },
    editAs:    'oneCell',
  })
}
```

## Option B — SheetJS (xlsx) — Simpler

```bash
npm install xlsx
npm install -D @types/xlsx
```

```typescript
import * as XLSX from 'xlsx'

export function generateSimpleXlsx(data: {
  headers: string[]
  rows:    (string | number | Date)[][]
  sheetName?: string
}): Buffer {
  const wb = XLSX.utils.book_new()

  // Convert to worksheet
  const wsData = [data.headers, ...data.rows]
  const ws     = XLSX.utils.aoa_to_sheet(wsData)

  // Set column widths
  ws['!cols'] = data.headers.map(() => ({ wch: 20 }))

  // Freeze top row
  ws['!freeze'] = { xSplit: 0, ySplit: 1 }

  XLSX.utils.book_append_sheet(wb, ws, data.sheetName ?? 'Sheet1')

  return Buffer.from(XLSX.write(wb, { type: 'buffer', bookType: 'xlsx' }))
}

// From an array of objects
export function objectsToXlsx<T extends Record<string, unknown>>(
  rows: T[],
  sheetName = 'Data'
): Buffer {
  const wb = XLSX.utils.book_new()
  const ws = XLSX.utils.json_to_sheet(rows)
  XLSX.utils.book_append_sheet(wb, ws, sheetName)
  return Buffer.from(XLSX.write(wb, { type: 'buffer', bookType: 'xlsx' }))
}
```

## NestJS Integration

```typescript
// exports/exports.service.ts
@Injectable()
export class ExportsService {
  constructor(private readonly ordersRepo: OrdersRepository) {}

  async exportOrders(filter: OrderFilterDto): Promise<Buffer> {
    const orders = await this.ordersRepo.findMany(filter)

    return generateExcelReport({
      columns: [
        { header: 'Order ID',    key: 'id',         width: 12 },
        { header: 'Customer',    key: 'customer',   width: 25 },
        { header: 'Date',        key: 'date',       width: 15, format: 'yyyy-mm-dd' },
        { header: 'Total',       key: 'total',      width: 15, format: '#,##0.00', align: 'right' },
        { header: 'Status',      key: 'status',     width: 15 },
      ],
      rows: orders.map(o => ({
        id:       o.id,
        customer: o.customer.name,
        date:     o.createdAt,
        total:    o.total,
        status:   o.status,
      })),
      summary: {
        id:       `Total: ${orders.length} orders`,
        customer: '',
        date:     '',
        total:    orders.reduce((sum, o) => sum + o.total, 0),
        status:   '',
      },
    })
  }
}

// exports/exports.controller.ts
@Get('orders.xlsx')
@UseGuards(JwtAuthGuard)
async exportOrders(
  @Query() filter: OrderFilterDto,
  @Res() res: Response,
) {
  const buffer = await this.exportsService.exportOrders(filter)
  const filename = `orders-${format(new Date(), 'yyyy-MM-dd')}.xlsx`

  res.set({
    'Content-Type':        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'Content-Disposition': `attachment; filename="${filename}"`,
    'Content-Length':      buffer.length,
  })

  res.end(buffer)
}
```

## Parsing Uploaded Excel Files

```typescript
import ExcelJS from 'exceljs'

async function parseUploadedExcel(buffer: Buffer): Promise<Record<string, unknown>[]> {
  const workbook = new ExcelJS.Workbook()
  await workbook.xlsx.load(buffer)

  const sheet = workbook.worksheets[0]
  if (!sheet) throw new Error('No worksheets found')

  const headers: string[] = []
  const rows: Record<string, unknown>[] = []

  sheet.eachRow((row, rowIndex) => {
    if (rowIndex === 1) {
      row.eachCell(cell => headers.push(String(cell.value ?? '')))
      return
    }

    const record: Record<string, unknown> = {}
    row.eachCell((cell, colIndex) => {
      const header = headers[colIndex - 1]
      if (header) record[header] = cell.value
    })
    rows.push(record)
  })

  return rows
}
```

## Forbidden Patterns

- Never use synchronous file writes (`workbook.xlsx.writeFile`) in a web server — always use `writeBuffer`
- Never pass unvalidated user data directly into cells — sanitize to prevent formula injection (`=SYSTEM()`)
- Never stream huge workbooks without chunking — build in batches for >100k rows
- Never trust uploaded Excel filenames — generate your own download filename
