import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  static const _navyBlue = PdfColor.fromInt(0xFF001F54);

  // ── Font cache — loaded once, reused across all generations ───────────────
  static pw.Font? _cachedRobotoBold;
  static pw.Font? _cachedMontserrat;

  static Future<(pw.Font?, pw.Font?)> _loadFonts() async {
    try {
      _cachedRobotoBold ??= await PdfGoogleFonts.robotoBold();
      _cachedMontserrat ??= await PdfGoogleFonts.montserratMedium();
    } catch (_) {
      // Fonts unavailable (offline) — fall back to default
    }
    return (_cachedRobotoBold, _cachedMontserrat);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED HEADER — logo + JAYASHREE (bold) FOUNDATION (normal) + Regd No.
  // ─────────────────────────────────────────────────────────────────────────
  static pw.Widget _buildHeader(pw.MemoryImage? logoImage, pw.Font? robotoBold, pw.Font? montserrat) {
    return pw.Center(
      child: pw.Column(
        children: [
          if (logoImage != null)
            pw.Container(height: 70, child: pw.Image(logoImage)),
          pw.SizedBox(height: 8),
          pw.RichText(
            textAlign: pw.TextAlign.center,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'JAYASHREE ',
                  style: pw.TextStyle(
                    font: robotoBold,
                    fontSize: 26,
                    fontWeight: robotoBold == null ? pw.FontWeight.bold : null,
                    color: PdfColors.black,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.TextSpan(
                  text: 'FOUNDATION',
                  style: pw.TextStyle(
                    font: montserrat,
                    fontSize: 26,
                    color: PdfColors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Regd. No.: MAH/509/2021/THANE',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  static const String _locationSvg = '''<svg viewBox="0 0 24 24"><path fill="#0F172A" d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>''';
  static const String _phoneSvg = '''<svg viewBox="0 0 24 24"><path fill="#64748B" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm4.4-6.4l-2.1-1.2c-.4-.2-.9-.1-1.1.3l-1 .8c-.5-.2-1.1-.6-1.6-1-.5-.5-.9-1.1-1-1.6l.8-1c.4-.3.5-.8.3-1.1L8.6 7.6c-.3-.4-.8-.5-1.2-.2L6 8.7c-.5.5-.7 1.3-.4 2 .8 1.5 2.5 3.2 4.8 4.5.8.4 1.7.2 2.3-.4l1.3-1.3c.5-.4.6-1 .3-1.4z"/></svg>''';
  static const String _emailSvg = '''<svg viewBox="0 0 24 24"><path fill="#64748B" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z"/><path fill="#64748B" d="M16 9H8c-1.1 0-2 .9-2 2v4c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2v-4c0-1.1-.9-2-2-2zm0 2l-4 2.5L8 11V9l4 2.5L16 9v2zm0 4H8v-3.5l4 2.5 4-2.5V15z"/></svg>''';
  static const String _webSvg = '''<svg viewBox="0 0 24 24"><path fill="#64748B" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/></svg>''';

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED FOOTER — address line above divider + phone / email / web
  // ─────────────────────────────────────────────────────────────────────────
  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.SvgImage(svg: _locationSvg, width: 12, height: 12),
            pw.SizedBox(width: 4),
            pw.Text(
              'Room No. 17, Plot No. 46, Sahyadri Society, Sector - 16A, Nerul, Navi Mumbai - 400 706',
              style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#334155'), fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 1, color: PdfColors.grey500),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.SvgImage(svg: _phoneSvg, width: 11, height: 11),
            pw.SizedBox(width: 4),
            pw.Text('+91 9321006900 / +91 8108710071',
                style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#475569'), fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 14),
            pw.SvgImage(svg: _emailSvg, width: 11, height: 11),
            pw.SizedBox(width: 4),
            pw.Text('info.jayashreefoundation@gmail.com',
                style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#475569'), fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 14),
            pw.SvgImage(svg: _webSvg, width: 11, height: 11),
            pw.SizedBox(width: 4),
            pw.Text('www.jayashreefoundation.org',
                style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#475569'), fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RECEIPT PDF
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Uint8List> generateReceiptPdf({
    required String receiptNo,
    required DateTime date,
    required String donorName,
    required double amount,
    required String amountWords,
    required String paymentMode,
    required String purpose,
    String? panNo,
    String? contactNo,
    String? email,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Ignore if logo fails to load
    }
    final (robotoBold, montserrat) = await _loadFonts();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(left: 40, right: 40, top: 36, bottom: 65),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(logoImage, robotoBold, montserrat),
              pw.SizedBox(height: 10),

              // Tax Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PAN: AAAETJ1922A',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                    pw.Text('12A: AAETJ1922A23MB01',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.Text('80G: AAETJ1922A23MB02',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  ]),
                ],
              ),
              pw.Divider(color: PdfColors.black),

              pw.Center(
                  child: pw.Text('RECEIPT',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.black))),
              pw.SizedBox(height: 14),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt No: $receiptNo',
                      style: const pw.TextStyle(color: PdfColors.black)),
                  pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}',
                      style: const pw.TextStyle(color: PdfColors.black)),
                ],
              ),
              pw.SizedBox(height: 14),

              pw.RichText(
                text: pw.TextSpan(children: [
                  const pw.TextSpan(
                      text: 'Received with thanks from Ms/Mr/Mrs: ',
                      style: pw.TextStyle(color: PdfColors.black)),
                  pw.TextSpan(
                      text: donorName,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                          color: PdfColors.black)),
                ]),
              ),
              pw.SizedBox(height: 14),

              pw.Row(children: [
                pw.Text('Amount: ', style: const pw.TextStyle(color: PdfColors.black)),
                pw.Text('Rs. ${amount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                        color: PdfColors.black)),
                pw.SizedBox(width: 16),
                pw.Text('The sum of Amount (in words): ',
                    style: const pw.TextStyle(color: PdfColors.black)),
                pw.Expanded(
                  child: pw.Text(amountWords,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                          color: PdfColors.black)),
                ),
              ]),
              pw.SizedBox(height: 14),

              pw.Row(children: [
                pw.Text('Cash/Draft/NEFT/RTGS/Cheque: ',
                    style: const pw.TextStyle(color: PdfColors.black)),
                pw.Text(paymentMode,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                        color: PdfColors.black)),
              ]),
              pw.SizedBox(height: 14),

              pw.Row(children: [
                pw.Text('Towards: ', style: const pw.TextStyle(color: PdfColors.black)),
                pw.Expanded(
                  child: pw.Text(purpose,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                          color: PdfColors.black)),
                ),
              ]),
              pw.SizedBox(height: 14),

              pw.Row(children: [
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(children: [
                      const pw.TextSpan(
                          text: 'Contact No: ', style: pw.TextStyle(color: PdfColors.black)),
                      pw.TextSpan(
                          text: contactNo ?? '_________________',
                          style: const pw.TextStyle(
                              decoration: pw.TextDecoration.underline, color: PdfColors.black)),
                    ]),
                  ),
                ),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(children: [
                      const pw.TextSpan(
                          text: 'Pan No: ', style: pw.TextStyle(color: PdfColors.black)),
                      pw.TextSpan(
                          text: panNo ?? '_________________',
                          style: const pw.TextStyle(
                              decoration: pw.TextDecoration.underline, color: PdfColors.black)),
                    ]),
                  ),
                ),
              ]),
              pw.SizedBox(height: 14),

              pw.RichText(
                text: pw.TextSpan(children: [
                  const pw.TextSpan(
                      text: 'E-Mail: ', style: pw.TextStyle(color: PdfColors.black)),
                  pw.TextSpan(
                      text: email ?? '_________________________________________',
                      style: const pw.TextStyle(
                          decoration: pw.TextDecoration.underline, color: PdfColors.black)),
                ]),
              ),

              pw.Spacer(),

              // Authorised signatory row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Subject to encashment of Cheque.',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
                  pw.Container(
                    width: 76,
                    height: 76,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _navyBlue, width: 2),
                    ),
                    child: pw.Center(
                      child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                        pw.Text('JAYASHREE',
                            style: pw.TextStyle(fontSize: 8, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                        pw.Text('FOUNDATION',
                            style: pw.TextStyle(fontSize: 8, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('MAH/509', style: const pw.TextStyle(fontSize: 6, color: _navyBlue)),
                        pw.Text('2021', style: const pw.TextStyle(fontSize: 6, color: _navyBlue)),
                        pw.SizedBox(height: 2),
                        pw.Text('NAVI MUMBAI', style: const pw.TextStyle(fontSize: 6, color: _navyBlue)),
                      ]),
                    ),
                  ),
                  pw.Column(children: [
                    pw.Text('Authorised Signatory',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 40),
                    pw.Container(width: 150, height: 1, color: PdfColors.black),
                  ]),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2, color: PdfColors.black),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'All Contributions for JAYASHREE FOUNDATION are exempted U/S 80G of I.T.Act 1961.',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                ),
              ),
              pw.SizedBox(height: 6),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTERNSHIP CERTIFICATE PDF
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Uint8List> generateCertificatePdf({
    required String certificateNo,
    required DateTime date,
    required String recipientName,
    String organisation = 'Jayashree Foundation',
    String internshipArea = 'Social Welfare & Community Development',
    String internshipDuration = '',
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Ignore
    }
    final (robotoBold, montserrat) = await _loadFonts();

    final String displayName =
        recipientName.trim().isEmpty ? '____________________' : recipientName;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(left: 50, right: 50, top: 40, bottom: 65),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(logoImage, robotoBold, montserrat),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey400, thickness: 0.5),
              pw.SizedBox(height: 10),

              // Certificate No & Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(children: [
                      pw.TextSpan(
                          text: 'Certificate No: ',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                      pw.TextSpan(
                          text: certificateNo,
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    ]),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(children: [
                      pw.TextSpan(
                          text: 'Date: ',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                      pw.TextSpan(
                          text: DateFormat('dd/MM/yyyy').format(date),
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    ]),
                  ),
                ],
              ),

              pw.SizedBox(height: 36),

              pw.Center(
                child: pw.Text(
                  'INTERNSHIP COMPLETION CERTIFICATE',
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                    color: PdfColors.black,
                  ),
                ),
              ),

              pw.SizedBox(height: 28),

              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: const pw.TextStyle(fontSize: 13, lineSpacing: 6, color: PdfColors.black),
                  children: [
                    const pw.TextSpan(text: 'This certificate is proudly presented to Mr./Ms. '),
                    pw.TextSpan(
                        text: displayName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(
                        text: ', for successfully completing his/her internship with '),
                    pw.TextSpan(
                        text: organisation,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(text: ' in the area of '),
                    pw.TextSpan(
                        text: internshipArea,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (internshipDuration.isNotEmpty) ...[
                      const pw.TextSpan(text: ' for the period '),
                      pw.TextSpan(
                          text: internshipDuration,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                    const pw.TextSpan(text: '.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: const pw.TextStyle(fontSize: 13, lineSpacing: 6, color: PdfColors.black),
                  children: [
                    const pw.TextSpan(
                        text:
                            'During the internship period, they actively contributed to various initiatives under the '),
                    pw.TextSpan(
                        text: internshipArea,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(text: ' domain organized by '),
                    pw.TextSpan(
                        text: organisation,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(
                        text:
                            '. Their responsibilities included assisting in program coordination, community outreach activities, awareness campaigns, and initiatives aimed at social empowerment and public welfare.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: const pw.TextStyle(fontSize: 13, lineSpacing: 6, color: PdfColors.black),
                  children: [
                    const pw.TextSpan(text: 'Throughout the internship, '),
                    pw.TextSpan(
                        text: displayName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(
                        text:
                            ' demonstrated excellent dedication, discipline, teamwork, and a strong willingness to learn. Their proactive approach and positive attitude greatly supported the objectives and activities of '),
                    pw.TextSpan(
                        text: organisation,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(text: '.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: const pw.TextStyle(fontSize: 13, lineSpacing: 6, color: PdfColors.black),
                  children: [
                    const pw.TextSpan(text: 'The management of '),
                    pw.TextSpan(
                        text: organisation,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(
                        text:
                            ' appreciates their valuable contribution and wishes them continued success in their academic journey and future professional career.'),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),
              pw.Text('Thank You!',
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),

              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JOINING LETTER PDF
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Uint8List> generateJoiningLetterPdf({
    required String name,
    required String tenure,
    required String requestDate,
    String? approvedBy,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Ignore
    }
    final (robotoBold, montserrat) = await _loadFonts();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(left: 50, right: 50, top: 40, bottom: 65),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(logoImage, robotoBold, montserrat),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 16),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Ref: JF/JL/${tenure.replaceAll(' ', '_')}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black)),
                  pw.Text('Date: $requestDate',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black)),
                ],
              ),

              pw.SizedBox(height: 36),
              pw.Center(
                child: pw.Text('VOLUNTEER JOINING / TENURE LETTER',
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                        color: PdfColors.black)),
              ),
              pw.SizedBox(height: 36),

              pw.Text('To,', style: const pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.Text(name,
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
              pw.Text('Volunteer, Jayashree Foundation',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.black)),

              pw.SizedBox(height: 28),
              pw.Text('Dear $name,',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.SizedBox(height: 14),

              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: const pw.TextStyle(fontSize: 12, lineSpacing: 5, color: PdfColors.black),
                  children: [
                    const pw.TextSpan(
                        text:
                            'This is to certify and formally record your association with Jayashree Foundation as a Volunteer for the tenure of '),
                    pw.TextSpan(
                        text: tenure,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    const pw.TextSpan(text: '.'),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Paragraph(
                text:
                    'During this period, you have been instrumental in supporting our various social welfare programs and community development initiatives. Your dedication towards "Helping Ray & Spreading Hope" has been valuable to the foundation and the communities we serve.',
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 5, color: PdfColors.black),
              ),

              pw.Paragraph(
                text:
                    'We appreciate the time and effort you have contributed towards our shared mission. This letter serves as an official confirmation of your active participation and contribution for the designated month.',
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 5, color: PdfColors.black),
              ),

              pw.SizedBox(height: 16),
              pw.Text('We look forward to your continued support.',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.black)),

              pw.Spacer(),

              // Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.SizedBox(height: 40),
                    pw.Text('Authorized Signatory',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black)),
                    pw.Text('Jayashree Foundation',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black)),
                  ]),
                  pw.Container(
                    width: 68,
                    height: 68,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _navyBlue, width: 1.5),
                    ),
                    child: pw.Center(
                      child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                        pw.Text('JAYASHREE',
                            style: pw.TextStyle(fontSize: 7, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                        pw.Text('FOUNDATION',
                            style: pw.TextStyle(fontSize: 7, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('MAH/509', style: const pw.TextStyle(fontSize: 5, color: _navyBlue)),
                        pw.SizedBox(height: 2),
                        pw.Text('NAVI MUMBAI', style: const pw.TextStyle(fontSize: 5, color: _navyBlue)),
                      ]),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GENERIC DOCUMENT PDF
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Uint8List> generateGenericDocumentPdf({
    required String title,
    required String category,
    required String date,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Ignore
    }
    final (robotoBold, montserrat) = await _loadFonts();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(left: 50, right: 50, top: 40, bottom: 65),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(logoImage, robotoBold, montserrat),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 24),

              pw.Center(
                child: pw.Text(title.toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                        color: PdfColors.black)),
              ),
              pw.SizedBox(height: 24),

              pw.Text('Category: $category',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
              pw.Text('Document Date: $date',
                  style: const pw.TextStyle(color: PdfColors.black)),
              pw.SizedBox(height: 24),

              pw.Text('CONTENT SUMMARY',
                  style:
                      pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
              pw.SizedBox(height: 10),
              pw.Paragraph(
                text:
                    'This document serves as an official record of Jayashree Foundation regarding "$title". The foundation adheres to all regulatory requirements and transparency standards in its operations.',
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 4, color: PdfColors.black),
              ),
              pw.Paragraph(
                text:
                    'Jayashree Foundation (Regd. No. MAH/509/2021/THANE) is committed to social empowerment and community development. This document is part of our standard operating protocol and holds official validity for its designated purpose within the organization.',
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 4, color: PdfColors.black),
              ),

              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
