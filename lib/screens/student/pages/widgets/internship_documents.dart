import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '/common/models/internship.dart';
import '/screens/internship_forms/generate_documents.dart';

class InternshipDocuments extends StatefulWidget {
  const InternshipDocuments({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipDocuments> createState() => _InternshipDocumentsState();
}

class _InternshipDocumentsState extends State<InternshipDocuments> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: ExpansionPanelList(
        elevation: 0,
        expansionCallback: (index, isExpanded) =>
            setState(() => _isExpanded = !_isExpanded),
        children: [
          ExpansionPanel(
            isExpanded: _isExpanded,
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) => Text('Documents',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black)),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPdfTile(
                  context,
                  title: 'Formulaire d\'identification du stagiaire',
                  pdfGeneratorCallback:
                      GenerateDocuments.generateStudentIdentificationPdf,
                ),
                ...List.generate(
                  widget.internship.nbVersions,
                  (index) => _buildPdfTile(
                    context,
                    title: 'Contrat de stage - Version du '
                        '${DateFormat('yMd', 'fr_CA').format(widget.internship.versionDateFrom(index))}',
                    pdfGeneratorCallback: (format, {required internship}) =>
                        GenerateDocuments.generateIntershipContractPdf(format,
                            internship: internship, versionIndex: index),
                  ),
                ),
                _buildPdfTile(
                  context,
                  title: 'Formulaire pour la CNESST',
                  pdfGeneratorCallback: GenerateDocuments.generateCnesstPdf,
                ),
                _buildPdfTile(
                  context,
                  title: 'Formulaire d\'autorisation de prise de photos',
                  pdfGeneratorCallback:
                      GenerateDocuments.generatePhotoAutorisationPdf,
                ),
                _buildPdfTile(
                  context,
                  title: 'Formulaire pour le crédit d\'impôts',
                  pdfGeneratorCallback:
                      GenerateDocuments.generateTaxeCreditFormPdf,
                ),
                _buildPdfTile(
                  context,
                  title: 'Formulaire de demande de carte de stage au Club '
                      'paritaire de l\'automobile',
                  pdfGeneratorCallback:
                      GenerateDocuments.generateInternshipAutomotiveCardPdf,
                ),
                _buildPdfTile(
                  context,
                  title: 'Preuve de couverture d\'assurances',
                  pdfGeneratorCallback: GenerateDocuments.generateInsurancePdf,
                ),
                _buildEvaluations(
                    title: 'Formulaire d\'évaluation des compétences',
                    evaluations: widget.internship.skillEvaluations,
                    pdfGeneratorCallback:
                        GenerateDocuments.generateSkillEvaluationPdf),
                _buildEvaluations(
                    title: 'Formulaire d\'évaluation de l\'attitude',
                    evaluations: widget.internship.attitudeEvaluations,
                    pdfGeneratorCallback:
                        GenerateDocuments.generateAttitudeEvaluationPdf),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPdfTile(
    BuildContext context, {
    required String title,
    required Future<Uint8List> Function(PdfPageFormat format,
            {required Internship internship})
        pdfGeneratorCallback,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => showDialog(
            context: context,
            builder: (ctx) => PdfPreview(
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  build: (format) => pdfGeneratorCallback(format,
                      internship: widget.internship),
                )),
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  Widget _buildEvaluations(
      {required String title,
      evaluations,
      required Future<Uint8List> Function(PdfPageFormat format,
              {required Internship internship, required int evaluationIndex})
          pdfGeneratorCallback}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (evaluations.isEmpty) const Text('Aucune évalution'),
                if (evaluations.isNotEmpty)
                  ...evaluations.asMap().keys.map(
                        (index) => _buildPdfTile(
                          context,
                          title: 'Formulaire du '
                              '${DateFormat('yMd', 'fr_CA').format(evaluations[index].date)}',
                          pdfGeneratorCallback: (format,
                                  {required internship}) =>
                              pdfGeneratorCallback(format,
                                  internship: internship,
                                  evaluationIndex: index),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
