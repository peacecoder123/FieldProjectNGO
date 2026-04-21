import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class PdfGeneratorService {
  static const _navyBlue = PdfColor.fromInt(0xFF001F54);
  static const _receiptHeaderColor = PdfColor.fromInt(0xFF002D62);

  static Future<Uint8List> generateReceiptPdf({
    required String receiptNo,
    required DateTime date,
    required String donorName,
    required double amount,
    String? amountWords,
    required String paymentMode,
    required String purpose,
    String? panNo,
    String? contactNo,
    String? email,
    bool is80G = false,
  }) async {
    final pdf = pw.Document();
    final words = amountWords ?? AppFormatters.numberToWords(amount);
    
    // Attempt to load logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Fallback
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header (NGO Info)
              pw.Center(
                child: pw.Column(
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        height: 70,
                        child: pw.Image(logoImage),
                      ),
                    pw.SizedBox(height: 8),
                    pw.Text('JAYASHREE FOUNDATION', 
                      style: pw.TextStyle(
                        fontSize: 22, 
                        fontWeight: pw.FontWeight.bold,
                        color: _receiptHeaderColor,
                      )
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text('Regd. No.: MAH/509/2021/THANE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Room No. 17, Plot No. 46, Sahyadri Society, Sector-16A, Nerul, Navi Mumbai - 400 706.', 
                      style: pw.TextStyle(fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              
              // 2. NGO ID Metadata (PAN, 12A, 80G)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PAN: AAAETJ1922A', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('12A: AAETJ1922A23MB01', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('80G: AAETJ1922A23MB02', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ]
                  )
                ]
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 1.5, color: PdfColors.black),
              
              // 3. Document Title
              pw.Center(child: pw.Text('RECEIPT', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 15),
              
              // 4. Receipt Header Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt No: $receiptNo', style: pw.TextStyle(fontSize: 11)),
                  pw.Text('Date: ${DateFormat('dd/04/2026').format(date)}', style: pw.TextStyle(fontSize: 11)), // Using user's sample style
                ]
              ),
              pw.SizedBox(height: 12),
              
              // 5. Main Body content
              pw.RichText(
                text: pw.TextSpan(
                  style: const pw.TextStyle(fontSize: 11),
                  children: [
                    pw.TextSpan(text: 'Received with thanks from Ms/Mr/Mrs: '),
                    pw.TextSpan(text: donorName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  ]
                )
              ),
              pw.SizedBox(height: 12),
              
              pw.Row(
                children: [
                  pw.Text('Amount: ', style: pw.TextStyle(fontSize: 11)),
                  pw.Text('Rs. ${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  pw.SizedBox(width: 25),
                  pw.Text('The sum of Amount (in words): ', style: pw.TextStyle(fontSize: 11)),
                  pw.Expanded(
                    child: pw.Text(words, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  )
                ]
              ),
              pw.SizedBox(height: 12),
              
              pw.Row(
                children: [
                  pw.Text('Cash/Draft/NEFT/RTGS/Cheque: ', style: pw.TextStyle(fontSize: 11)),
                  pw.Text(paymentMode.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                ]
              ),
              pw.SizedBox(height: 12),
              
              pw.Row(
                children: [
                  pw.Text('Towards: ', style: pw.TextStyle(fontSize: 11)),
                  pw.Expanded(
                    child: pw.Text(purpose, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  )
                ]
              ),
              pw.SizedBox(height: 12),
              
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.RichText(
                      text: pw.TextSpan(
                        style: const pw.TextStyle(fontSize: 10),
                        children: [
                          pw.TextSpan(text: 'Contact No: '),
                          pw.TextSpan(text: contactNo ?? '_________________', style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
                        ]
                      )
                    )
                  ),
                  pw.Expanded(
                    child: pw.RichText(
                      text: pw.TextSpan(
                        style: const pw.TextStyle(fontSize: 10),
                        children: [
                          pw.TextSpan(text: 'Pan No: '),
                          pw.TextSpan(text: panNo ?? '_________________', style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
                        ]
                      )
                    )
                  )
                ]
              ),
              pw.SizedBox(height: 12),
              
              pw.RichText(
                text: pw.TextSpan(
                  style: const pw.TextStyle(fontSize: 10),
                  children: [
                    pw.TextSpan(text: 'E-Mail: '),
                    pw.TextSpan(text: email ?? '_________________________________________', style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
                  ]
                )
              ),
              
              pw.Spacer(),
              
              // 6. Signature & Seal Area
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 5),
                    child: pw.Text('Subject to encashment of Cheque.', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                  ),
                  
                  // Circular NGO Seal
                  pw.Container(
                    width: 75,
                    height: 75,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _navyBlue, width: 1.5),
                    ),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('JAYASHREE', style: pw.TextStyle(fontSize: 7, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.Text('FOUNDATION', style: pw.TextStyle(fontSize: 7, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 1),
                          pw.Text('MAH/509', style: pw.TextStyle(fontSize: 5, color: _navyBlue)),
                          pw.Text('2021', style: pw.TextStyle(fontSize: 5, color: _navyBlue)),
                          pw.SizedBox(height: 1),
                          pw.Text('NAVI MUMBAI', style: pw.TextStyle(fontSize: 5, color: _navyBlue)),
                        ]
                      )
                    )
                  ),
                  
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Authorised Signatory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.SizedBox(height: 35),
                      pw.Container(width: 140, height: 1.2, color: PdfColors.black),
                    ]
                  )
                ]
              ),
              
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'All Contributions for JAYASHREE FOUNDATION are exempted U/S 80G of I.T.Act 1961.',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header
              pw.Center(
                child: pw.Column(
                  children: [
                    if (logoImage != null)
                      pw.Container(height: 80, child: pw.Image(logoImage)),
                    pw.SizedBox(height: 15),
                    pw.Text(organisation.toUpperCase(), 
                      style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _navyBlue, letterSpacing: 2)
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Regd. No.: MAH/509/2021/THANE', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 20),
              
              // 2. Metadata
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Certificate No: $certificateNo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]
              ),
              pw.SizedBox(height: 50),
              
              // 3. Title
              pw.Center(
                child: pw.Text('INTERNSHIP COMPLETION CERTIFICATE', 
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)
                ),
              ),
              pw.SizedBox(height: 40),
              
              // 4. Body
              pw.Paragraph(
                text: 'This certificate is proudly presented to Mr./Ms. ${recipientName.isEmpty ? '____________________' : recipientName}, for successfully completing his/her internship with $organisation in the area of $internshipArea${internshipDuration.isNotEmpty ? ' for the period $internshipDuration' : ''}.',
                style: pw.TextStyle(fontSize: 13, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'During the internship period, they actively contributed to various initiatives under the $internshipArea domain organized by $organisation. Their responsibilities included assisting in program coordination, community outreach activities, awareness campaigns, and initiatives aimed at social empowerment and public welfare.',
                style: pw.TextStyle(fontSize: 13, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'Throughout the internship, ${recipientName.isEmpty ? 'the candidate' : recipientName} demonstrated excellent dedication, discipline, teamwork, and a strong willingness to learn. Their proactive approach and positive attitude greatly supported the objectives and activities of $organisation.',
                style: pw.TextStyle(fontSize: 13, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'The management of $organisation appreciates their valuable contribution and wishes them continued success in their academic journey and future professional career.',
                style: pw.TextStyle(fontSize: 13, lineSpacing: 5),
              ),
              
              pw.SizedBox(height: 10),
              pw.Text('Thank You!', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              
              pw.Spacer(),
              
              // 5. Signatures & Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1.2, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text('President', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text(organisation, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    ]
                  ),
                  
                  // Circular NGO Seal
                  pw.Container(
                    width: 75,
                    height: 75,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _navyBlue, width: 1.5),
                    ),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('JAYASHREE', style: pw.TextStyle(fontSize: 7, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.Text('FOUNDATION', style: pw.TextStyle(fontSize: 7, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 1),
                          pw.Text('MAH/509', style: pw.TextStyle(fontSize: 5, color: _navyBlue)),
                          pw.Text('2021', style: pw.TextStyle(fontSize: 5, color: _navyBlue)),
                        ]
                      )
                    )
                  ),
                ]
              ),
              
              pw.SizedBox(height: 30),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text('Room No. 17, Sector-16A, Nerul, Navi Mumbai - 400 706 | info.jayashreefoundation@gmail.com',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                )
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    if (logoImage != null)
                      pw.Container(height: 75, child: pw.Image(logoImage)),
                    pw.SizedBox(height: 10),
                    pw.Text('JAYASHREE FOUNDATION', 
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _navyBlue)
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Regd. No.: MAH/509/2021/THANE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Helping Ray & Spreading Hope', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
              pw.Divider(thickness: 1, color: _navyBlue),
              pw.SizedBox(height: 20),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Ref: JF/JL/${tenure.replaceAll(' ', '_')}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Date: $requestDate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ]
              ),
              
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text('VOLUNTEER JOINING / TENURE LETTER', 
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)
                ),
              ),
              pw.SizedBox(height: 35),
              
              pw.Text('To,', style: pw.TextStyle(fontSize: 11)),
              pw.Text(name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text('Volunteer, Jayashree Foundation', style: pw.TextStyle(fontSize: 10)),
              
              pw.SizedBox(height: 25),
              pw.Text('Dear $name,', style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 15),
              
              pw.Paragraph(
                text: 'This is to formally record your association with Jayashree Foundation as a Volunteer for the tenure of $tenure.',
                style: pw.TextStyle(fontSize: 11, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'Your dedication towards "Helping Ray & Spreading Hope" has been valuable to the foundation and the communities we serve. We appreciate the time and effort you have contributed towards our shared mission.',
                style: pw.TextStyle(fontSize: 11, lineSpacing: 5),
              ),
              
              pw.SizedBox(height: 20),
              pw.Text('We look forward to your continued support.', style: pw.TextStyle(fontSize: 11)),
              
              pw.Spacer(),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 40),
                      pw.Text('Authorized Signatory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Jayashree Foundation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ]
                  ),
                  
                  // Circular NGO Seal
                  pw.Container(
                    width: 70,
                    height: 70,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _navyBlue, width: 1.5),
                    ),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('JAYASHREE', style: pw.TextStyle(fontSize: 7, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.Text('FOUNDATION', style: pw.TextStyle(fontSize: 7, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                        ]
                      )
                    )
                  ),
                ]
              ),
              
              pw.SizedBox(height: 30),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'Room No. 17, Sector-16A, Nerul, Navi Mumbai - 400 706 | info.jayashreefoundation@gmail.com',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                )
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  static Future<Uint8List> generateGenericDocumentPdf({
    required String title,
    required String category,
    required String date,
  }) async {
    // ... existing code ...
    final pdf = pw.Document();
    
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Column(
                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                     children: [
                        pw.Text('JAYASHREE FOUNDATION', 
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _navyBlue)
                        ),
                        pw.Text('Official NGO Document', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                     ]
                   ),
                   if (logoImage != null) pw.Container(height: 40, child: pw.Image(logoImage)),
                ]
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: _navyBlue),
              pw.SizedBox(height: 30),
              
              pw.Center(
                child: pw.Text(title.toUpperCase(), 
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)
                ),
              ),
              pw.SizedBox(height: 30),
              
              pw.Text('Category: $category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Document Date: $date'),
              pw.SizedBox(height: 30),
              
              pw.Text('CONTENT SUMMARY', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Paragraph(
                text: 'This document serves as an official record of Jayashree Foundation regarding "$title". The foundation adheres to all regulatory requirements and transparency standards in its operations.',
                style: pw.TextStyle(fontSize: 12, lineSpacing: 4),
              ),
              pw.Paragraph(
                text: 'Jayashree Foundation (Regd. No. MAH/509/2021/THANE) is committed to social empowerment and community development. This document is part of our standard operating protocol and holds official validity for its designated purpose within the organization.',
                style: pw.TextStyle(fontSize: 12, lineSpacing: 4),
              ),
              
              pw.Spacer(),
              
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('(c) ${DateTime.now().year} Jayashree Foundation', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  pw.Text('Page 1 of 1', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                ]
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  static Future<Uint8List> generateMouAcceptancePdf({
    required String patientName,
    required String hospitalName,
    required String address,
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. NGO Header (Matching provided image)
              pw.Center(
                child: pw.Column(
                  children: [
                    if (logoImage != null)
                      pw.Container(height: 85, child: pw.Image(logoImage)),
                    pw.SizedBox(height: 8),
                    pw.Text('JAYASHREE FOUNDATION', 
                      style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: _navyBlue, letterSpacing: 1.5)
                    ),
                    pw.Text('Regd. No.: MAH/509/2021/THANE', 
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // 2. Recipient & Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('To,', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Management/ Administration,', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(hospitalName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text(address, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ]
                  ),
                  pw.Text('Date - $date', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                ]
              ),
              pw.SizedBox(height: 35),
              
              // 3. Subject
              pw.RichText(
                text: pw.TextSpan(
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
                  children: [
                    pw.TextSpan(text: 'Subject - ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                      text: 'To Provide Discount/Concession to the below mentioned member as per MOU signed.',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
                    ),
                  ]
                )
              ),
              pw.SizedBox(height: 25),
              
              // 4. Salutation
              pw.Text('Respected Sir/Madam,', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              
              // 5. Letter Body
              pw.Paragraph(
                margin: const pw.EdgeInsets.all(0),
                text: 'I Secretary of Jayashree Foundation confirm that $patientName is a member of our foundation and I request you to do the needful as per the signed MOU with the $hospitalName.',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, lineSpacing: 4),
              ),
              
              pw.Spacer(),
              
              // 6. Signature Area (Kept blank as per user instruction)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 60), // Space for signature
                      pw.Text('Rutuja Puppalwar', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Secretary', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Jayashree Foundation .', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ]
                  ),
                  // Space for Stamp
                  pw.Container(
                    width: 100,
                    height: 100,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.white, width: 0), // Hidden border
                    ),
                  )
                ]
              ),
              
              pw.SizedBox(height: 40),
              
              // 7. Footer Info (Redesigned with SVG icons to match image 2)
              pw.Center(
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.SvgImage(
                      svg: '<svg viewBox="0 0 24 24"><path fill="#334155" d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>',
                      width: 10,
                      height: 10,
                    ),
                    pw.SizedBox(width: 4),
                    pw.Text('Room No. 17, Plot No. 46, Sahyadri Society, Sector - 16A, Nerul, Navi Mumbai - 400 706',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1e293b'))
                    ),
                  ]
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 1, color: PdfColor.fromHex('#94a3b8')),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Row(
                    children: [
                      pw.SvgImage(
                        svg: '<svg viewBox="0 0 24 24"><path fill="#334155" d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/></svg>',
                        width: 8,
                        height: 8,
                      ),
                      pw.SizedBox(width: 3),
                      pw.Text('+91 9321006900 / +91 8108710071', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#334155'))),
                    ]
                  ),
                  pw.Row(
                    children: [
                      pw.SvgImage(
                        svg: '<svg viewBox="0 0 24 24"><path fill="#334155" d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg>',
                        width: 10,
                        height: 10,
                      ),
                      pw.SizedBox(width: 3),
                      pw.Text('info.jayashreefoundation@gmail.com', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#334155'))),
                    ]
                  ),
                  pw.Row(
                    children: [
                      pw.SvgImage(
                        svg: '<svg viewBox="0 0 24 24"><path fill="#334155" d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zm6.93 6h-2.95c-.32-1.25-.78-2.45-1.38-3.56 1.84.63 3.37 1.91 4.33 3.56zM12 4.04c.83 1.2 1.48 2.53 1.91 3.96h-3.82c.43-1.43 1.08-2.76 1.91-3.96zM4.26 14C4.1 13.36 4 12.69 4 12s.1-1.36.26-2h3.38c-.09.66-.14 1.32-.14 2 0 .68.05 1.34.14 2H4.26zm.82 2h2.95c.32 1.25.78 2.45 1.38 3.56-1.84-.63-3.37-1.91-4.33-3.56zm2.95-8H5.08c.96-1.65 2.49-2.93 4.33-3.56-.6 1.11-1.06 2.31-1.38 3.56zM12 19.96c-.83-1.2-1.48-2.53-1.91-3.96h3.82c-.43 1.43-1.08-2.76-1.91-3.96zM14.34 14H9.66c-.09-.66-.14-1.32-.14-2 0-.68.05-1.34.14-2h4.68c.09.66.14 1.32.14 2 0 .68-.05 1.34-.14 2zm.44 5.56c.6-1.11 1.06-2.31 1.38-3.56h2.95c-.96 1.65-2.49 2.93-4.33 3.56zM16.36 14c.09-.66.14-1.32.14-2 0-.68-.05-1.34-.14-2h3.38c.16.64.26 1.31.26 2s-.1 1.36-.26 2h-3.38z"/></svg>',
                        width: 9,
                        height: 9,
                      ),
                      pw.SizedBox(width: 3),
                      pw.Text('www.jayashreefoundation.org', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#334155'))),
                    ]
                  ),
                ]
              )
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
}
