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
                    pw.Text('JAYASHREE FOUNDATION', 
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
                text: 'This certificate is proudly presented to Mr./Ms. ${recipientName.isEmpty ? '____________________' : recipientName}, for successfully completing his/her internship with Jayashree Foundation.',
                style: pw.TextStyle(fontSize: 13, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'During the internship period, they actively contributed to various social welfare initiatives. Their dedication, discipline, and teamwork greatly supported the objectives of the foundation.',
                style: pw.TextStyle(fontSize: 13, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'We appreciate their valuable contribution and wish them continued success in their future professional career.',
                style: pw.TextStyle(fontSize: 13, lineSpacing: 5),
              ),
              
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
                      pw.Text('Jayashree Foundation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
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
}
