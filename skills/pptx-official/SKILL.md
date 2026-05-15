---
name: pptx-official
description: Generating PowerPoint presentations with pptxgenjs in Node.js. Use when creating automated presentations, slide decks, pitch decks, or reports in .pptx format from data.
---

# PowerPoint Generation with pptxgenjs

## Installation

```bash
npm install pptxgenjs
npm install -D @types/node
```

## Basic Presentation

```typescript
import PptxGenJS from 'pptxgenjs'

async function generatePresentation(data: PresentationData): Promise<Buffer> {
  const pptx = new PptxGenJS()

  // Global settings
  pptx.author  = 'Antigravity HQ'
  pptx.company = 'Antigravity'
  pptx.title   = data.title
  pptx.subject = data.subject
  pptx.layout  = 'LAYOUT_WIDE'  // 16:9

  // ─── Title Slide ─────────────────────────────────────────
  const titleSlide = pptx.addSlide()
  titleSlide.background = { color: '1E3A5F' }

  titleSlide.addText(data.title, {
    x:     '10%',
    y:     '35%',
    w:     '80%',
    h:     '20%',
    fontSize:  40,
    bold:      true,
    color:     'FFFFFF',
    align:     'center',
    fontFace:  'Calibri',
  })

  titleSlide.addText(data.subtitle, {
    x:        '15%',
    y:        '60%',
    w:        '70%',
    h:        '10%',
    fontSize: 20,
    color:    'B0C4DE',
    align:    'center',
  })

  titleSlide.addText(new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long' }), {
    x:        '0%',
    y:        '88%',
    w:        '100%',
    h:        '8%',
    fontSize: 12,
    color:    '7094B5',
    align:    'center',
  })

  // ─── Content Slides ───────────────────────────────────────
  for (const section of data.sections) {
    addContentSlide(pptx, section)
  }

  // ─── Chart Slide ──────────────────────────────────────────
  if (data.chartData) {
    addChartSlide(pptx, data.chartData)
  }

  // ─── Summary Slide ────────────────────────────────────────
  addSummarySlide(pptx, data.keyPoints)

  // Return as buffer
  const buffer = await pptx.write({ outputType: 'nodebuffer' }) as Buffer
  return buffer
}
```

## Content Slide with Bullets

```typescript
function addContentSlide(pptx: PptxGenJS, section: Section) {
  const slide = pptx.addSlide()

  // Slide header bar
  slide.addShape(pptx.ShapeType.rect, {
    x: 0, y: 0, w: '100%', h: 0.8,
    fill: { color: '2563EB' },
    line: { color: '2563EB' },
  })

  // Title
  slide.addText(section.title, {
    x:        0.3,
    y:        0.1,
    w:        '90%',
    h:        0.6,
    fontSize: 22,
    bold:     true,
    color:    'FFFFFF',
    fontFace: 'Calibri',
  })

  // Bullet points
  slide.addText(
    section.bullets.map(bullet => ({
      text:    bullet,
      options: {
        bullet: { type: 'bullet', characterCode: '25CF' }, // filled circle
        paraSpaceAfter: 8,
      },
    })),
    {
      x:        0.5,
      y:        1.1,
      w:        '90%',
      h:        '75%',
      fontSize: 16,
      color:    '374151',
      fontFace: 'Calibri',
      valign:   'top',
    }
  )

  // Slide number
  slide.addText(`${section.slideNumber}`, {
    x:        '93%',
    y:        '92%',
    w:        '5%',
    h:        '6%',
    fontSize: 10,
    color:    '9CA3AF',
    align:    'right',
  })
}
```

## Chart Slide

```typescript
function addChartSlide(pptx: PptxGenJS, chartData: ChartData) {
  const slide = pptx.addSlide()

  // Header
  slide.addShape(pptx.ShapeType.rect, {
    x: 0, y: 0, w: '100%', h: 0.8,
    fill: { color: '2563EB' },
    line: { color: '2563EB' },
  })
  slide.addText(chartData.title, {
    x: 0.3, y: 0.1, w: '90%', h: 0.6,
    fontSize: 22, bold: true, color: 'FFFFFF',
  })

  // Bar chart
  slide.addChart(pptx.ChartType.bar, [
    {
      name:   chartData.seriesName,
      labels: chartData.labels,
      values: chartData.values,
    },
  ], {
    x:     0.5,
    y:     1.0,
    w:     9.0,
    h:     5.0,
    chartColors:  ['2563EB', '10B981', 'F59E0B', 'EF4444'],
    showValue:    true,
    showLegend:   true,
    legendPos:    'b',
    dataLabelFontSize: 10,
    catAxisLabelFontSize: 11,
    valAxisLabelFontSize: 11,
    title:         chartData.title,
    showTitle:     false,
  })
}

// Line chart for trends
slide.addChart(pptx.ChartType.line, [
  { name: 'Revenue', labels: months, values: revenueData },
  { name: 'Costs',   labels: months, values: costData },
], {
  x: 0.5, y: 1.0, w: 9.0, h: 5.0,
  lineSize:    2,
  showLegend:  true,
  showMarker:  true,
  chartColors: ['2563EB', 'EF4444'],
})
```

## Table Slide

```typescript
function addTableSlide(pptx: PptxGenJS, tableData: TableData) {
  const slide = pptx.addSlide()

  const rows: PptxGenJS.TableRow[] = [
    // Header row
    tableData.headers.map(h => ({
      text: h,
      options: {
        bold:     true,
        color:    'FFFFFF',
        fill:     { color: '2563EB' },
        fontSize: 12,
        align:    'center' as const,
      },
    })),
    // Data rows
    ...tableData.rows.map((row, i) =>
      row.map(cell => ({
        text: cell,
        options: {
          fontSize: 11,
          color:    '374151',
          fill:     i % 2 === 0 ? { color: 'F8FAFC' } : { color: 'FFFFFF' },
        },
      }))
    ),
  ]

  slide.addTable(rows, {
    x:     0.3,
    y:     1.0,
    w:     9.4,
    border: { type: 'solid', color: 'E5E7EB', pt: 0.5 },
    colW:  tableData.columnWidths,
  })
}
```

## NestJS Integration

```typescript
// presentations/presentations.service.ts
@Injectable()
export class PresentationsService {
  async generateReport(reportId: string): Promise<Buffer> {
    const report = await this.reportsRepo.findOneOrFail(reportId)

    return generatePresentation({
      title:    report.title,
      subtitle: report.period,
      subject:  'Monthly Report',
      sections: report.sections.map(s => ({
        title:  s.heading,
        bullets: s.points,
        slideNumber: s.order,
      })),
      chartData: {
        title:      'Revenue Trend',
        seriesName: 'Revenue',
        labels:     report.chart.months,
        values:     report.chart.values,
      },
      keyPoints: report.summary,
    })
  }
}

// presentations/presentations.controller.ts
@Get(':id/pptx')
@UseGuards(JwtAuthGuard)
async downloadPptx(
  @Param('id') id: string,
  @Res() res: Response,
) {
  const buffer = await this.presentationsService.generateReport(id)

  res.set({
    'Content-Type':        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'Content-Disposition': `attachment; filename="report-${id}.pptx"`,
    'Content-Length':      buffer.length,
  })

  res.end(buffer)
}
```

## Forbidden Patterns

- Never use absolute pixel values for positioning — use percentages or inch values for portability
- Never forget to `await pptx.write()` — it returns a Promise
- Never include user-provided text without escaping HTML entities in text fields
- Never create slides in a loop without checking memory — large decks need streaming or chunking
