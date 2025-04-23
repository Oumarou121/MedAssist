import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

void showDialogConfirm({
  required BuildContext context,
  required BuildContext? contextParent,
  required Future<void> Function() action1,
  required VoidCallback action2,
  required String msg,
  bool isAlert = false,
}) {
  bool isLoading = false;
  showDialog(
    barrierDismissible: false,
    context: context,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalStateDialog) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5F7FB), Colors.white],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 40,
                      color: isAlert ? Colors.red : const Color(0xFF00C853),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Do you want to confirm",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text("cancel".tr()),
                            onPressed: () {
                              if (!isLoading) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isAlert
                                      ? Colors.red
                                      : const Color(0xFF00C853),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      setModalStateDialog(
                                        () => isLoading = true,
                                      );

                                      final navigator = Navigator.of(context);
                                      final navigatorParent =
                                          contextParent != null
                                              ? Navigator.of(contextParent)
                                              : null;

                                      try {
                                        await action1();
                                        action2();

                                        if (navigator.canPop()) navigator.pop();
                                        if (navigatorParent?.canPop() ??
                                            false) {
                                          navigatorParent!.pop();
                                        }
                                      } catch (e) {
                                        // Handle error if needed
                                      } finally {
                                        setModalStateDialog(
                                          () => isLoading = false,
                                        );
                                      }
                                    },
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                    : Text(
                                      "confirm".tr(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
  );
}
