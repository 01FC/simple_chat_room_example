part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class VerifyLogInEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoginWithFacebookEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoginWithGoogleEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class LoginWithEmailEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class ForgotPasswordEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}
