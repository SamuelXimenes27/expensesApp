import 'package:expenses/app/modules/userDetails/user_details_page.dart';
import 'package:flutter/material.dart';

class CustomAppBarWidgetTitle extends StatelessWidget {
  final String? title;
  const CustomAppBarWidgetTitle({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: size.height * 0.12,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 40, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfilePage(),
                          ));
                    },
                    icon: const Icon(
                      Icons.person,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
