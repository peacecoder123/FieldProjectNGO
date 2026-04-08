import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfGeneratorService {
  static const _navyBlue = PdfColor.fromInt(0xFF001F54);

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
    
    // Attempt to load logo, fallback gracefully if not found
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Ignore if logo fails to load (might not be available during tests)
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        height: 80,
                        child: pw.Image(logoImage),
                      ),
                    pw.SizedBox(height: 10),
                    pw.Text('JAYASHREE FOUNDATION', 
                      style: pw.TextStyle(
                        fontSize: 24, 
                        fontWeight: pw.FontWeight.bold,
                        color: _navyBlue,
                      )
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Regd. No.: MAH/509/2021/THANE', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Room No. 17, Plot No. 46, Sahyadri Society, Sector-16A, Nerul, Navi Mumbai - 400 706.', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Tax Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PAN: AAAETJ1922A', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('12A: AAETJ1922A23MB01', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('80G: AAETJ1922A23MB02', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ]
                  )
                ]
              ),
              pw.Divider(),
              
              // Title
              pw.Center(child: pw.Text('RECEIPT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),
              
              // Body
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt No: $receiptNo'),
                  pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}'),
                ]
              ),
              pw.SizedBox(height: 15),
              
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: 'Received with thanks from Ms/Mr/Mrs: '),
                    pw.TextSpan(text: donorName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  ]
                )
              ),
              pw.SizedBox(height: 15),
              
              pw.Row(
                children: [
                  pw.Text('Amount: '),
                  pw.Text('Rs. ${amount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  pw.SizedBox(width: 20),
                  pw.Text('The sum of Amount (in words): '),
                  pw.Expanded(
                    child: pw.Text(amountWords, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  )
                ]
              ),
              pw.SizedBox(height: 15),
              
              pw.Row(
                children: [
                  pw.Text('Cash/Draft/NEFT/RTGS/Cheque: '),
                  pw.Text(paymentMode, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                ]
              ),
              pw.SizedBox(height: 15),
              
              pw.Row(
                children: [
                  pw.Text('Towards: '),
                  pw.Expanded(
                    child: pw.Text(purpose, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                  )
                ]
              ),
              pw.SizedBox(height: 15),
              
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.RichText(
                      text: pw.TextSpan(
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
                        children: [
                          pw.TextSpan(text: 'Pan No: '),
                          pw.TextSpan(text: panNo ?? '_________________', style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
                        ]
                      )
                    )
                  )
                ]
              ),
              pw.SizedBox(height: 15),
              
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: 'E-Mail: '),
                    pw.TextSpan(text: email ?? '_________________________________________', style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
                  ]
                )
              ),
              
              pw.Spacer(),
              
              // Signatures & Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Subject to encashment of Cheque.', style: pw.TextStyle(fontSize: 10)),
                  // Simulated Seal
                  pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _navyBlue, width: 2),
                    ),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('JAYASHREE', style: pw.TextStyle(fontSize: 8, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.Text('FOUNDATION', style: pw.TextStyle(fontSize: 8, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text('MAH/509', style: pw.TextStyle(fontSize: 6, color: _navyBlue)),
                          pw.Text('2021', style: pw.TextStyle(fontSize: 6, color: _navyBlue)),
                          pw.SizedBox(height: 2),
                          pw.Text('NAVI MUMBAI', style: pw.TextStyle(fontSize: 6, color: _navyBlue)),
                        ]
                      )
                    )
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Authorised Signatory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 40),
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                    ]
                  )
                ]
              ),
              
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'All Contributions for JAYASHREE FOUNDATION are exempted U/S 80G of I.T.Act 1961.',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
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
      // Ignore if logo fails to load
    }

    final String displayName = recipientName.trim().isEmpty ? '____________________' : recipientName;

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
                      pw.Container(
                        height: 100,
                        child: pw.Image(logoImage),
                      ),
                    pw.SizedBox(height: 20),
                    pw.Text('JAYASHREE FOUNDATION', 
                      style: pw.TextStyle(
                        fontSize: 28, 
                        fontWeight: pw.FontWeight.bold,
                        color: _navyBlue,
                        letterSpacing: 2,
                      )
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Regd. No.: MAH/509/2021/THANE', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Certificate No: $certificateNo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]
              ),
              
              pw.SizedBox(height: 60),
              
              pw.Center(
                child: pw.Text('INTERNSHIP COMPLETION CERTIFICATE', 
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)
                ),
              ),
              
              pw.SizedBox(height: 40),
              
              pw.Paragraph(
                text: 'This certificate is proudly presented to Mr./Ms. $displayName, for successfully completing his/her internship with Jayashree Foundation.',
                style: pw.TextStyle(fontSize: 14, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'During the internship period, they actively contributed to various social welfare and community development initiatives organized by the foundation. Their responsibilities included assisting in program coordination, community outreach activities, awareness campaigns, and initiatives aimed at social empowerment and public welfare.',
                style: pw.TextStyle(fontSize: 14, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'Throughout the internship, $displayName demonstrated excellent dedication, discipline, teamwork, and a strong willingness to learn. Their proactive approach and positive attitude greatly supported the objectives and activities of the foundation.',
                style: pw.TextStyle(fontSize: 14, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'The management of Jayashree Foundation appreciates their valuable contribution and wishes them continued success in their academic journey and future professional career.',
                style: pw.TextStyle(fontSize: 14, lineSpacing: 5),
              ),
              
              pw.SizedBox(height: 10),
              pw.Text('Thank You!', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              
              pw.Spacer(),
              
              // Signatures & Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text('President', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Jayashree Foundation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]
                  ),
                  
                  // Projected Seal
                  pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: _navyBlue, width: 2),
                    ),
                    child: pw.Center(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('JAYASHREE', style: pw.TextStyle(fontSize: 8, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.Text('FOUNDATION', style: pw.TextStyle(fontSize: 8, color: _navyBlue, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text('MAH/509', style: pw.TextStyle(fontSize: 6, color: _navyBlue)),
                          pw.Text('2021', style: pw.TextStyle(fontSize: 6, color: _navyBlue)),
                          pw.SizedBox(height: 2),
                          pw.Text('NAVI MUMBAI', style: pw.TextStyle(fontSize: 6, color: _navyBlue)),
                        ]
                      )
                    )
                  ),
                ]
              ),
              
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'Room No. 17, Plot No. 46, Sahyadri Society, Sector-16A, Nerul, Navi Mumbai - 400 706',
                  style: pw.TextStyle(fontSize: 9),
                )
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text('+91 9321006900 / +91 8108710071', style: pw.TextStyle(fontSize: 9)),
                  pw.Text('info.jayashreefoundation@gmail.com', style: pw.TextStyle(fontSize: 9)),
                  pw.Text('www.jayashreefoundation.org', style: pw.TextStyle(fontSize: 9)),
                ]
              )
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
      // Ignore if logo fails to load
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
                      pw.Container(
                        height: 80,
                        child: pw.Image(logoImage),
                      ),
                    pw.SizedBox(height: 10),
                    pw.Text('JAYASHREE FOUNDATION', 
                      style: pw.TextStyle(
                        fontSize: 24, 
                        fontWeight: pw.FontWeight.bold,
                        color: _navyBlue,
                      )
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Regd. No.: MAH/509/2021/THANE', style: pw.TextStyle(fontSize: 10)),
                    pw.Text('Helping Ray & Spreading Hope', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
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
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)
                ),
              ),
              pw.SizedBox(height: 40),
              
              pw.Text('To,', style: pw.TextStyle(fontSize: 12)),
              pw.Text(name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('Volunteer, Jayashree Foundation', style: pw.TextStyle(fontSize: 11)),
              
              pw.SizedBox(height: 30),
              pw.Text('Dear $name,', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 15),
              
              pw.Paragraph(
                text: 'This is to certify and formally record your association with Jayashree Foundation as a Volunteer for the tenure of $tenure.',
                style: pw.TextStyle(fontSize: 12, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'During this period, you have been instrumental in supporting our various social welfare programs and community development initiatives. Your dedication towards "Helping Ray & Spreading Hope" has been valuable to the foundation and the communities we serve.',
                style: pw.TextStyle(fontSize: 12, lineSpacing: 5),
              ),
              
              pw.Paragraph(
                text: 'We appreciate the time and effort you have contributed towards our shared mission. This letter serves as an official confirmation of your active participation and contribution for the designated month.',
                style: pw.TextStyle(fontSize: 12, lineSpacing: 5),
              ),
              
              pw.SizedBox(height: 20),
              pw.Text('We look forward to your continued support.', style: pw.TextStyle(fontSize: 12)),
              
              pw.Spacer(),
              
              // Signatures & Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 40),
                      pw.Text('Authorized Signatory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Jayashree Foundation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    ]
                  ),
                  
                  // Simulated Seal
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
                          pw.SizedBox(height: 2),
                          pw.Text('MAH/509', style: pw.TextStyle(fontSize: 5, color: _navyBlue)),
                          pw.SizedBox(height: 2),
                          pw.Text('NAVI MUMBAI', style: pw.TextStyle(fontSize: 5, color: _navyBlue)),
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
}

