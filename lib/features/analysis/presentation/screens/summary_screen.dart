import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:legalx/core/services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, dynamic>? analysisData;
  const SummaryScreen({super.key, this.analysisData});

  @override
  Widget build(BuildContext context) {
    // Handle nested extra data from ProcessingScreen
    final Map<String, dynamic>? data = analysisData?['analysisData'];
    final Uint8List? fileBytes = analysisData?['fileBytes'];
    final String? extension = analysisData?['extension'];
    final String fullText = data?['full_text'] ?? '';

    final int score = data?['risk_score'] ?? 82;
    final String summaryText = data?['summary'] ?? 
        'This Service Agreement is generally favorable but contains specific risk vectors in liability and termination. Ledger synchronized.';
    final List<dynamic> risks = data?['risks'] ?? [
      {'title': 'Indemnity Mismatch', 'description': 'Clause 4.2 requires uncapped liability. (Indian Contract Act Sec 73)', 'isHigh': true},
      {'title': 'Automatic Renewal', 'description': '90-day cancellation notice required.', 'isHigh': false},
    ];
    final List<dynamic> missingClauses = data?['missing_clauses'] ?? [
      'Missing "Force Majeure" (Act of God) protection clause.',
      'No explicit termination rules outlining your exit strategy.',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ANALYSIS SUMMARY',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ledger Score Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  if (data?['is_offline'] == true)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Icon(Icons.security_rounded, color: Colors.cyanAccent, size: 14),
                           SizedBox(width: 8),
                           Text('PROCESSED LOCALLY', style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 8,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          color: score > 70 ? AppColors.secondary : Colors.orange,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'SCORE',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ledger Integrity: ${score > 75 ? 'High' : 'Moderate'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Divider(height: 32),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gavel_rounded, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Legal Intelligence Tool: Not a Law Firm',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Quick Intelligence',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                summaryText,
                style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Key Risk Vectors',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...risks.map((risk) => _RiskVectorTile(
              title: risk['title'] ?? 'Unknown Vector',
              description: risk['description'] ?? 'No data provided',
              isHigh: risk['isHigh'] ?? false,
            )).toList(),
            const SizedBox(height: 40),
            Row(
              children: [
                const Icon(Icons.search_off_rounded, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  'Blindspot Detective',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.blueAccent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Crucial protective clauses that the other party deceptively removed or forgot to include.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...missingClauses.map((clause) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 16),
                  Expanded(child: Text(clause.toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent))),
                ],
              ),
            )).toList(),

            const SizedBox(height: 48),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.language_rounded),
              onPressed: () {
                 showModalBottomSheet(
                   context: context,
                   isScrollControlled: true,
                   backgroundColor: Colors.transparent,
                   builder: (context) => _BabelDecoderSheet(text: fullText.isNotEmpty ? fullText : summaryText),
                 );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              label: const Text(
                'BABEL TRANSLATOR (PUNJABI/HINDI)',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.forum_rounded),
              onPressed: () => context.push('/chat', extra: fullText.isNotEmpty ? fullText : summaryText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              label: const Text(
                'CHAT WITH CASE AI',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 16),
            if (fileBytes != null && (extension?.toLowerCase() == 'jpg' || extension?.toLowerCase() == 'jpeg' || extension?.toLowerCase() == 'png'))
              ElevatedButton.icon(
                icon: const Icon(Icons.center_focus_strong_rounded),
                onPressed: () {
                   showDialog(
                     context: context,
                     builder: (context) => _VisualEvidenceDialog(imageBytes: fileBytes, risks: risks),
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                label: const Text(
                  'SCAN FOR VISUAL EVIDENCE',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/risk-heatmap'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      minimumSize: const Size(0, 64),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('SURFACE MAP', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                       showModalBottomSheet(
                         context: context,
                         isScrollControlled: true,
                         backgroundColor: Colors.transparent,
                         builder: (context) => _FullSimplificationSheet(text: fullText.isNotEmpty ? fullText : summaryText),
                       );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 64),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text('SIMPLIFY DOC', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: () => _exportPdf(context, summaryText, risks, score),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              label: const Text(
                'DOWNLOAD LEGAL AUDIT REPORT',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, String summary, List<dynamic> risks, int score) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text('LEGALX AI - DOCUMENT AUDIT REPORT')),
          pw.SizedBox(height: 20),
          pw.Text('Overall Risk Score: $score/100'),
          pw.SizedBox(height: 20),
          pw.Text('Summary: $summary'),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Key Risk Vectors')),
          ...risks.map((risk) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${risk['title']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${risk['description']}'),
              pw.SizedBox(height: 10),
            ],
          )),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

class _RiskVectorTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isHigh;

  const _RiskVectorTile({
    required this.title,
    required this.description,
    required this.isHigh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHigh ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isHigh ? Icons.gpp_bad_rounded : Icons.info_outline_rounded,
              color: isHigh ? const Color(0xFFC62828) : const Color(0xFFEF6C00),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.outlineVariant),
        ],
      ),
    );
  }
}

class _FullSimplificationSheet extends StatefulWidget {
  final String text;
  const _FullSimplificationSheet({required this.text});

  @override
  State<_FullSimplificationSheet> createState() => _FullSimplificationSheetState();
}

class _FullSimplificationSheetState extends State<_FullSimplificationSheet> {
  final GeminiService _geminiService = GeminiService();
  String? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _simplify();
  }

  Future<void> _simplify() async {
    final res = await _geminiService.simplifyLegalText(widget.text);
    if (mounted) {
      setState(() {
        _result = res;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI SIMPLIFICATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, color: Colors.purple)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(color: Colors.purple))
              : Markdown(
                  data: _result!,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16, height: 1.6),
                    h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                    h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                    listBullet: const TextStyle(color: Colors.purple),
                  ),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('GOT IT', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _BabelDecoderSheet extends StatefulWidget {
  final String text;
  const _BabelDecoderSheet({required this.text});

  @override
  State<_BabelDecoderSheet> createState() => _BabelDecoderSheetState();
}

class _BabelDecoderSheetState extends State<_BabelDecoderSheet> {
  final GeminiService _geminiService = GeminiService();
  String? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _translate();
  }

  Future<void> _translate() async {
    final prompt = "Act as the 'Babel Legal Decoder'. Translate the following legal text into very simple, conversational Punjabi and Hindi (mixed or separated clearly) so a villager or non-English speaker can easily understand their rights and risks. TEXT: ${widget.text}";
    final res = await _geminiService.simplifyLegalText(prompt);
    if (mounted) {
      setState(() {
        _result = res;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BABEL DECODER (TECH FOR GOOD)', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.indigo)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
              : Markdown(
                  data: _result ?? 'Translation failed.',
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16, height: 1.6),
                    h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    listBullet: const TextStyle(color: Colors.indigo),
                  ),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('UNDERSTOOD', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _VisualEvidenceDialog extends StatelessWidget {
  final Uint8List imageBytes;
  final List<dynamic> risks;

  const _VisualEvidenceDialog({required this.imageBytes, required this.risks});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text('VISUAL EVIDENCE MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Text('AI detected risk coordinates shown in red boxes.', style: TextStyle(color: Colors.white60, fontSize: 10)),
                     ],
                   ),
                   IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: InteractiveViewer(
                  maxScale: 5.0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Image.memory(imageBytes, fit: BoxFit.contain, width: constraints.maxWidth, height: constraints.maxHeight),
                          // Draw Bounding Boxes
                          ...risks.where((r) => r['box_2d'] != null).map((risk) {
                            final box = List<dynamic>.from(risk['box_2d']);
                            if (box.length == 4) {
                              final double ymin = (box[0] as num).toDouble() / 1000.0;
                              final double xmin = (box[1] as num).toDouble() / 1000.0;
                              final double ymax = (box[2] as num).toDouble() / 1000.0;
                              final double xmax = (box[3] as num).toDouble() / 1000.0;

                              return Positioned(
                                left: xmin * constraints.maxWidth,
                                top: ymin * constraints.maxHeight,
                                width: (xmax - xmin) * constraints.maxWidth,
                                height: (ymax - ymin) * constraints.maxHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.redAccent, width: 3),
                                    color: Colors.redAccent.withOpacity(0.15),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      risk['title'] ?? 'RISK',
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, backgroundColor: Colors.redAccent),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

