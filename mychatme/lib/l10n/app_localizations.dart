// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';
//import 'package:mychatme/l10n/app_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Para textos con parámetro (como videoCallWith(name))
  String videoCallWith(String name) {
    if (locale.languageCode == 'es') {
      return 'Videollamada con $name';
    } else {
      return 'Video call with $name';
    }
  }

  //
  String chatWith(String name) {
  if (locale.languageCode == 'es') {
    return 'Chat con $name';
  } else {
    return 'Chat with $name';
  }
}

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Método auxiliar para evitar repetir locale.languageCode
  String _t(String key) {
    return _localizedValues[locale.languageCode]![key] ?? key;
  }

   // Texto dinámico con parámetro
  //String videoCallWith(String name) => _t('video_call_with') + ' $name';

  // === Getters generales ===
  String get welcome => _t('welcome');
  String get error => _t('error');
  String get tryAgain => _t('try_again');
  String get connectionError => _t('connection_error');
  String get serverError => _t('server_error');
  String get unknownError => _t('unknown_error');
  String get yes => _t('yes');
  String get no => _t('no');

  // Login y Registro
  String get login => _t('login');
  String get register => _t('register');
  String get email => _t('email');
  String get password => _t('password');
  String get forgotPassword => _t('forgot_password');
  String get loginWithGoogle => _t('login_with_google');
  String get dontHaveAccount => _t('dont_have_account');
  String get createAccount => _t('create_account');
  String get name => _t('name');
  String get confirmPassword => _t('confirm_password');
  String get alreadyHaveAccount => _t('already_have_account');
  String get loginError => _t('login_error');
  String get invalidEmail => _t('invalid_email');
  String get userDisabled => _t('user_disabled');
  String get userNotFound => _t('user_not_found');
  String get wrongPassword => _t('wrong_password');
  String get registerError => _t('register_error');
  String get weakPassword => _t('weak_password');
  String get emailInUse => _t('email_in_use');
  String get passwordsNotMatch => _t('passwords_not_match');
  String get registrationSuccess => _t('registration_success');
  String get signUp => _t('sign_up');
  String get signIn => _t('sign_in');
  String get signInWithGoogle => _t('sign_in_with_google');
  String get enterYourAccount => _t('enter_your_account');
  String get googleSignInFailed => _t('google_sign_in_failed');
  String get googleUser => _t('google_user');
  String get authenticationError => _t('authentication_error');


  // Navegación
  String get home => _t('home');
  String get chats => _t('chats');
  String get contacts => _t('contacts');
  String get calls => _t('calls');
  String get settings => _t('settings');
  String get search => _t('search');
  String get newChat => _t('new_chat');

  // Chat
  String get typeMessage => _t('type_message');
  String get send => _t('send');
  String get noMessages => _t('no_messages');
  String get deleteMessage => _t('delete_message');
  String get delete => _t('delete');
  String get cancel => _t('cancel');

  // Contactos
  String get contactsPermission => _t('contacts_permission');
  String get grantPermission => _t('grant_permission');
  String get noContacts => _t('no_contacts');
  String get invite => _t('invite');
  String get startChat => _t('start_chat');

  // Llamadas
  String get callHistory => _t('call_history');
  String get missed => _t('missed');
  String get outgoing => _t('outgoing');
  String get incoming => _t('incoming');
  String get videoCall => _t('video_call');
  String get voiceCall => _t('voice_call');

  // Configuración
  String get profile => _t('profile');
  String get notifications => _t('notifications');
  String get privacy => _t('privacy');
  String get language => _t('language');
  String get help => _t('help');
  String get logout => _t('logout');
  String get logoutConfirmation => _t('logout_confirmation');

  // Perfil
  String get editProfile => _t('edit_profile');
  String get changePhoto => _t('change_photo');
  String get status => _t('status');
  String get about => _t('about');
  String get phoneNumber => _t('phone_number');
  String get saveChanges => _t('save_changes');
  String get changesSaved => _t('changes_saved');

  // Verificación de correo
  String get verifyYourEmail => _t('verify_your_email');
  String get verificationEmailSentToYou => _t('verification_email_sent_to_you');
  String get alreadyVerifiedDemo => _t('already_verified_demo');
  String get resendEmail => _t('resend_email');
  String get errorResending => _t('error_resending');
  String get emailVerifiedSuccessfully => _t('email_verified_successfully');
  String get emailNotVerifiedYet => _t('email_not_verified_yet');

  // Videollamada
  String get selectContactForVideoCall => _t('select_contact_for_video_call');
  String get noContactsAvailable => _t('no_contacts_available');
  String get waitingForOtherParticipant => _t('waiting_for_other_participant');
  String get connectingToCall => _t('connecting_to_call');

  //Cambiar password
  String get enterAndConfirmNewPassword => _t('enter_and_confirm_new_password');
  String get newPassword => _t('new_password');
  String get confirmNewPassword => _t('confirm_new_password');
  String get noMessagesYet => _t('no_messages_yet');

  //Contactos/contactos dispositivos
  String get phoneContacts => _t('phone_contacts');
  String get noContactsFound => _t('no_contacts_found');
  String get noNumber => _t('no_number');

  //Olvidaste contrasena
  String get recoverPassword => _t('recover_password');
  String get enterEmailToResetPassword => _t('enter_email_to_reset_password');
  String get passwordResetEmailSent => _t('password_reset_email_sent');
  String get pleaseEnterValidEmail => _t('please_enter_valid_email');
  String get sendLink => _t('send_link');

  //chat/regisro
  String get chat => _t('chat');
  String get passwordsDontMatch => _t('passwords_dont_match');
  String get verificationEmailSent => _t('verification_email_sent');
  String get errorRegisteringUser => _t('error_registering_user');
  String get emailAlreadyInUse => _t('email_already_in_use');
  String get createYourNewAccount => _t('create_your_new_account');
  String get requiredField => _t('required_field');
  String get minimumSixCharacters => _t('minimum_six_characters');
  String get role => _t('role');
  String get verificationEmailResent => _t('verification_email_resent');

  // Otros
  String get openSettings => _t('open_settings');
  String get changePassword => _t('change_password');
  String get administrator => _t('administrator');
  String get user => _t('user');


  static const Map<String, Map<String, String>> _localizedValues = {
  'es': {
    // General
    'welcome': 'Bienvenido',
    'error': 'Error',
    'try_again': 'Intentar nuevamente',
    'connection_error': 'Error de conexión',
    'server_error': 'Error del servidor',
    'unknown_error': 'Error desconocido',
    'yes': 'Sí',
    'no': 'No',

    // Login y Registro
    'login': 'Iniciar Sesión',
    'register': 'Registrarse',
    'email': 'Correo Electrónico',
    'password': 'Contraseña',
    'forgot_password': '¿Olvidaste tu contraseña?',
    'login_with_google': 'Iniciar con Google',
    'dont_have_account': '¿No tienes una cuenta?',
    'create_account': 'Crear Cuenta',
    'name': 'Nombre',
    'confirm_password': 'Confirmar Contraseña',
    'already_have_account': '¿Ya tienes una cuenta?',
    'login_error': 'Error al iniciar sesión',
    'invalid_email': 'Correo electrónico inválido',
    'user_disabled': 'Usuario deshabilitado',
    'user_not_found': 'Usuario no encontrado',
    'wrong_password': 'Contraseña incorrecta',
    'register_error': 'Error al registrarse',
    'weak_password': 'Contraseña débil',
    'email_in_use': 'Correo ya en uso',
    'passwords_not_match': 'Las contraseñas no coinciden',
    'registration_success': 'Registro exitoso',
    'sign_up': 'Registrarse',
    'sign_in': 'Iniciar sesión',
    'sign_in_with_google': 'Iniciar sesión con Google',
    'enter_your_account': 'Ingresa a tu cuenta',
    'google_sign_in_failed': 'Error al iniciar sesión con Google',
    'google_user': 'Usuario de Google',
    'authentication_error': 'Error de autenticación',

    // Pantalla principal y navegación
    'home': 'Inicio',
    'chats': 'Chats',
    'contacts': 'Contactos',
    'calls': 'Llamadas',
    'settings': 'Configuración',
    'search': 'Buscar...',
    'new_chat': 'Nuevo chat',

    // Chat
    'type_message': 'Escribe un mensaje...',
    'send': 'Enviar',
    'no_messages': 'No hay mensajes',
    'delete_message': 'Eliminar mensaje',
    'delete': 'Eliminar',
    'cancel': 'Cancelar',

    // Contactos
    'contacts_permission': 'Permiso de contactos',
    'grant_permission': 'Conceder permiso',
    'no_contacts': 'No hay contactos',
    'invite': 'Invitar',
    'start_chat': 'Iniciar chat',

    // Llamadas
    'call_history': 'Historial de llamadas',
    'missed': 'Perdidas',
    'outgoing': 'Salientes',
    'incoming': 'Entrantes',
    'video_call': 'Videollamada',
    'voice_call': 'Llamada de voz',

    // Configuración
    'profile': 'Perfil',
    'notifications': 'Notificaciones',
    'privacy': 'Privacidad',
    'language': 'Idioma',
    'help': 'Ayuda',
    'logout': 'Cerrar sesión',
    'logout_confirmation': '¿Estás seguro de que quieres cerrar sesión?',

    // Perfil
    'edit_profile': 'Editar perfil',
    'change_photo': 'Cambiar foto',
    'status': 'Estado',
    'about': 'Acerca de',
    'phone_number': 'Número de teléfono',
    'save_changes': 'Guardar cambios',
    'changes_saved': 'Cambios guardados',

    // Pantalla VerifyEmailScreen
    'verify_your_email': 'Verifica tu correo electrónico',
    'verification_email_sent_to_you': 'Se ha enviado un correo de verificación a tu email.',
    'already_verified_demo': 'Ya verifiqué mi correo',
    'resend_email': 'Reenviar correo',
    'error_resending': 'Error al reenviar el correo',
    'email_verified_successfully': 'Correo verificado correctamente',
    'email_not_verified_yet': 'El correo aún no está verificado',

    // Pantalla VideoCallContactsScreen
    'select_contact_for_video_call': 'Selecciona un contacto para videollamada',
    'no_contacts_available': 'No hay contactos disponibles',

    // Pantalla VideoCallScreen
    'waiting_for_other_participant': 'Esperando al otro participante...',
    'connecting_to_call': 'Conectando a la llamada...',
    'video_call_with': 'Videollamada con', // texto base para concatenar

    //Pantalla ChangePassword
    'enter_and_confirm_new_password': 'Ingresa y confirma tu nueva contraseña',
    'new_password': 'Nueva contraseña',
    'confirm_new_password': 'Confirmar nueva contraseña',
    'no_messages_yet': 'Aún no hay mensajes',

    //Pantalla de contactos/contactos de dispositivo
   'phone_contacts': 'Contactos del teléfono',
   'no_contacts_found': 'No se encontraron contactos',
   'no_number': 'Sin número',

   //Pantalla olvidaste contrasena
   'recover_password': 'Recuperar contraseña',
   'enter_email_to_reset_password': 'Ingresa tu correo para restablecer la contraseña',
    'password_reset_email_sent': 'Correo para restablecer la contraseña enviado',
    'please_enter_valid_email': 'Por favor ingresa un correo válido',
    'send_link': 'Enviar enlace',
    
    //chat/registro
    'chat': 'Chat',
    'passwords_dont_match': 'Las contraseñas no coinciden',
    'verification_email_sent': 'Correo de verificación enviado',
    'error_registering_user': 'Error al registrar usuario',
    'email_already_in_use': 'Correo ya en uso',
    'create_your_new_account': 'Crea tu nueva cuenta',
    'required_field': 'Campo requerido',
    'minimum_six_characters': 'Mínimo 6 caracteres',
    'role': 'Rol',

    // Otros textos que puedas necesitar
    'open_settings': 'Abrir configuración',
    'change_password': 'Cambiar contraseña',
    'administrator': 'Administrador',
    'user': 'Usuario',
    'verification_email_resent': 'Correo de verificación reenviado',
  },
  'en': {
    // General
    'welcome': 'Welcome',
    'error': 'Error',
    'try_again': 'Try again',
    'connection_error': 'Connection error',
    'server_error': 'Server error',
    'unknown_error': 'Unknown error',
    'yes': 'Yes',
    'no': 'No',

    // Login and Register
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'forgot_password': 'Forgot password?',
    'login_with_google': 'Login with Google',
    'dont_have_account': 'Don\'t have an account?',
    'create_account': 'Create Account',
    'name': 'Name',
    'confirm_password': 'Confirm Password',
    'already_have_account': 'Already have an account?',
    'login_error': 'Login error',
    'invalid_email': 'Invalid email',
    'user_disabled': 'User disabled',
    'user_not_found': 'User not found',
    'wrong_password': 'Wrong password',
    'register_error': 'Registration error',
    'weak_password': 'Weak password',
    'email_in_use': 'Email already in use',
    'passwords_not_match': 'Passwords don\'t match',
    'registration_success': 'Registration successful',
    'sign_up': 'Sign Up',
    'sign_in': 'Sign In',
    'sign_in_with_google': 'Sign in with Google',
    'enter_your_account': 'Enter your account',
    'google_sign_in_failed': 'Google sign-in failed',
    'google_user': 'Google user',
    'authentication_error': 'Authentication error',

    // Main screen & navigation
    'home': 'Home',
    'chats': 'Chats',
    'contacts': 'Contacts',
    'calls': 'Calls',
    'settings': 'Settings',
    'search': 'Search...',
    'new_chat': 'New chat',

    // Chat
    'type_message': 'Type a message...',
    'send': 'Send',
    'no_messages': 'No messages',
    'delete_message': 'Delete message',
    'delete': 'Delete',
    'cancel': 'Cancel',

    // Contacts
    'contacts_permission': 'Contacts permission',
    'grant_permission': 'Grant permission',
    'no_contacts': 'No contacts',
    'invite': 'Invite',
    'start_chat': 'Start chat',

    // Calls
    'call_history': 'Call history',
    'missed': 'Missed',
    'outgoing': 'Outgoing',
    'incoming': 'Incoming',
    'video_call': 'Video call',
    'voice_call': 'Voice call',

    // Settings
    'profile': 'Profile',
    'notifications': 'Notifications',
    'privacy': 'Privacy',
    'language': 'Language',
    'help': 'Help',
    'logout': 'Logout',
    'logout_confirmation': 'Are you sure you want to logout?',

    // Profile
    'edit_profile': 'Edit profile',
    'change_photo': 'Change photo',
    'status': 'Status',
    'about': 'About',
    'phone_number': 'Phone number',
    'save_changes': 'Save changes',
    'changes_saved': 'Changes saved',

    // VerifyEmailScreen
    'verify_your_email': 'Verify your email',
    'verification_email_sent_to_you': 'A verification email has been sent to you.',
    'already_verified_demo': 'I\'ve already verified my email',
    'resend_email': 'Resend Email',
    'error_resending': 'Error resending email',
    'email_verified_successfully': 'Email verified successfully',
    'email_not_verified_yet': 'Email not verified yet',

    // VideoCallContactsScreen
    'select_contact_for_video_call': 'Select a contact for video call',
    'no_contacts_available': 'No contacts available',

    // VideoCallScreen
    'waiting_for_other_participant': 'Waiting for the other participant...',
    'connecting_to_call': 'Connecting to call...',
    'video_call_with': 'Video call with', // base text to append name

    // ChangePassword
    'enter_and_confirm_new_password': 'Enter and confirm your new password',
    'new_password': 'New password',
    'confirm_new_password': 'Confirm new password',
    'no_messages_yet': 'No messages yet',

    //Contacts/ContactsDevice
    'phone_contacts': 'Phone contacts',
    'no_contacts_found': 'No contacts found',
     'no_number': 'No number',

     //chat/register
     'chat': 'Chat',
     'passwords_dont_match': 'Passwords don\'t match',
     'verification_email_sent': 'Verification email sent',
     'error_registering_user': 'Error registering user',
     'email_already_in_use': 'Email already in use',
     'create_your_new_account': 'Create your new account',
     'required_field': 'Required field',
     'minimum_six_characters': 'Minimum six characters',

     //Forgot password
     'recover_password': 'Recover Password',
     'enter_email_to_reset_password': 'Enter your email to reset password',
     'password_reset_email_sent': 'Password reset email sent',
     'please_enter_valid_email': 'Please enter a valid email',
     'send_link': 'Send link',
     'role': 'Role',

    // Others
    'open_settings': 'Open settings',
    'change_password': 'Change password',
    'administrator': 'Administrator',
    'user': 'User',
    'verification_email_resent': 'Verification email resent',
  },
};
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}