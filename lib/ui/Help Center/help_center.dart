import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenter extends StatelessWidget {
  const HelpCenter({super.key});

  Future<void> openEmail() async {
    final Uri gmailUri = Uri.parse(
      'googlegmail://co?to=mainulappstorehelp@gmail.com'
          '&subject=${Uri.encodeComponent('App Feedback')}'
          '&body=${Uri.encodeComponent('Write your problem here...')}',
    );
    final Uri defaultUri = Uri.parse(
      'mailto:mainulappstorehelp@gmail.com'
          '?subject=${Uri.encodeComponent('App Feedback')}'
          '&body=${Uri.encodeComponent('Write your problem here...')}',
    );
    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri);
    } else {
      await launchUrl(defaultUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: const Text('Help Center'),
      ),

      body: Center(
        child:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            height: 300,
            width: double.infinity,
            //color: Colors.white54,
            decoration: BoxDecoration(
                color: const Color(0xFF2893B8),
              borderRadius: BorderRadius.circular(20)
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 19,
                    fontFamily: 'Regular',
                    color: const Color(0xFFBBFAFF),
                    fontWeight: FontWeight.w800
                  ),
                ),

                Text(
                    'Were here to assist you anytime',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Regular',
                      color: const Color(0xFFBBFAFF),
                      fontWeight: FontWeight.w800
                  ),
                ),

                SizedBox(height: 10),
                _SectionCard(
                    label: 'CONTACT US',
                    child: _ContactTile(onTap: openEmail)
                )
                

              ],

            ),
          ),
        )
      ),

    );
  }
}

class _SectionCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _SectionCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: const Color(0xFFE6F1FB),
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Email Contact Tile ──
class _ContactTile extends StatelessWidget {
  final VoidCallback onTap;
  const _ContactTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color(0xFFE6F1FB).withOpacity(0.6),
              width: 0.5
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.email_outlined,
                  color: Color(0xFF185FA5), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email Support',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        color: const Color(0xFFBBFAFF)

                      )),
                  SizedBox(height: 2),
                  Text('mainulappstorehelp@gmail.com',
                      style: TextStyle(fontSize: 12,
                          color: const Color(0xFF94EAF1)

                      )),
                ],
              ),
            ),
            const Icon(
                Icons.chevron_right,
                color: const Color(0xFFE6F1FB),
                size: 20,

            ),
          ],
        ),
      ),
    );
  }
}
