import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_padding.dart';
import '../../../../core/constants/app_spacing.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
          AuthEvent.otpVerificationRequested(
            email: context.read<AuthBloc>().state.email,
            otp: _otpController.text.trim(),
          ),
        );
  }

  void _resend() {
    context.read<AuthBloc>().add(
          AuthEvent.otpResendRequested(
            email: context.read<AuthBloc>().state.email,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AuthBloc>().add(
                  const AuthEvent.backToLoginRequested(),
                );
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppPadding.screen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxContentWidth,
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final loading = state.operation != AuthOperation.idle;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 72,
                        color: colors.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Check your inbox',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Enter the six-digit code sent to:',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        state.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        controller: _otpController,
                        enabled: !loading,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [
                          AutofillHints.oneTimeCode,
                        ],
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Verification code',
                          counterText: '',
                        ),
                        onSubmitted: (_) {
                          if (!loading) _verify();
                        },
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.error),
                        ),
                      ],
                      if (state.successMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          state.successMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.primary),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: AppDimensions.buttonHeight,
                        child: FilledButton(
                          onPressed: loading ? null : _verify,
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text('Verify and Continue'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: loading ? null : _resend,
                        child: const Text('Resend verification code'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'The code expires after 5 minutes. '
                        'You can request another code after '
                        'the server cooldown has elapsed.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
