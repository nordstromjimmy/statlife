import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Translations map
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Welcome & Auth
      'app_name': 'Evolvem',
      'welcome_tagline': 'Level up your life, one task at a time',
      'create_account': 'Create Account',
      'try_as_guest': 'Try as Guest',
      'sign_in': 'Sign in',
      'sign_up': 'Sign Up',
      'sign_out': 'Sign Out',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'already_have_account': 'Already have an account? Sign in',
      'dont_have_account': "Don't have an account? Sign up",
      'join_evolvem': 'Join Evolvem',
      'welcome_back': 'Welcome back!',
      'sign_in_to_continue': 'Sign in to continue your journey',

      // Home & Navigation
      'today': 'Today',
      'plan': 'Plan',
      'profile': 'Profile',
      'welcome_user': 'Welcome back,',
      'welcome_guest': 'Welcome, Guest',

      // Tasks
      'add_task': 'Add task',
      'task_title': 'Task title',
      'from_goal': 'From goal (optional)',
      'none': 'None',
      'start': 'Start',
      'end': 'End',
      'tasks': 'tasks',
      'done': 'done',

      // Goals
      'add_goal': 'Add',
      'goals': 'Goals',
      'no_goals_yet': 'No goals yet.\nAdd one to create tasks faster.',
      'goal_title': 'Goal title',
      'default_duration': 'Default duration (minutes)',
      'save': 'Save',
      'delete': 'Delete',
      'cancel': 'Cancel',

      // Profile
      'name': 'Name',
      'edit_name': 'Edit Name',
      'your_name': 'Your name',
      'not_set': 'Not set',
      'level': 'LEVEL',
      'xp_progress': 'XP Progress',
      'to_level': 'to Level',
      'statistics': 'Statistics',
      'completed': 'Completed',
      'total_tasks': 'Total Tasks',
      'completion': 'Completion',
      'total_xp': 'Total XP',
      'account_info': 'Account Info',
      'member_since': 'Member since',
      'days_active': 'Days active',
      'day': 'day',
      'days': 'days',

      // Guest Banner
      'unlock_full_potential': 'Unlock Full Potential',
      'create_account_to_save':
          'Create an account to save your progress and never lose your data',

      // Sign Out Dialog
      'sign_out_title': 'Sign Out',
      'sign_out_message':
          'Are you sure you want to sign out? Your data will remain synced in the cloud.',

      // Plan Screen
      'overview': 'Overview',
      'week': 'Week',
      'month': 'Month',

      // Features
      'plan_your_days': 'Plan your days with ease',
      'earn_xp_level_up': 'Earn XP and level up',
      'track_your_goals': 'Track your goals',

      // Errors
      'error_loading': 'Error loading',
      'sign_up_failed': 'Sign up failed',
      'sign_in_failed': 'Sign in failed',

      // Validation
      'enter_email': 'Please enter your email',
      'valid_email': 'Please enter a valid email',
      'enter_password': 'Please enter a password',
      'password_min_length': 'Password must be at least 6 characters',
      'passwords_no_match': 'Passwords do not match',
    },
    'sv': {
      // Welcome & Auth
      'app_name': 'Evolvem',
      'welcome_tagline': 'Förbättra ditt liv, en uppgift i taget',
      'create_account': 'Skapa konto',
      'try_as_guest': 'Prova som gäst',
      'sign_in': 'Logga in',
      'sign_up': 'Registrera',
      'sign_out': 'Logga ut',
      'email': 'E-post',
      'password': 'Lösenord',
      'confirm_password': 'Bekräfta lösenord',
      'already_have_account': 'Har du redan ett konto? Logga in',
      'dont_have_account': 'Har du inget konto? Registrera',
      'join_evolvem': 'Gå med i Evolvem',
      'welcome_back': 'Välkommen tillbaka!',
      'sign_in_to_continue': 'Logga in för att fortsätta din resa',

      // Home & Navigation
      'today': 'Idag',
      'plan': 'Planera',
      'profile': 'Profil',
      'welcome_user': 'Välkommen tillbaka,',
      'welcome_guest': 'Välkommen, Gäst',

      // Tasks
      'add_task': 'Lägg till uppgift',
      'task_title': 'Uppgiftstitel',
      'from_goal': 'Från mål (valfritt)',
      'none': 'Ingen',
      'start': 'Start',
      'end': 'Slut',
      'tasks': 'uppgifter',
      'done': 'klara',

      // Goals
      'add_goal': 'Lägg till',
      'goals': 'Mål',
      'no_goals_yet':
          'Inga mål ännu.\nLägg till ett för att skapa uppgifter snabbare.',
      'goal_title': 'Måltitel',
      'default_duration': 'Standardvaraktighet (minuter)',
      'save': 'Spara',
      'delete': 'Ta bort',
      'cancel': 'Avbryt',

      // Profile
      'name': 'Namn',
      'edit_name': 'Redigera namn',
      'your_name': 'Ditt namn',
      'not_set': 'Inte angett',
      'level': 'NIVÅ',
      'xp_progress': 'XP-framsteg',
      'to_level': 'till nivå',
      'statistics': 'Statistik',
      'completed': 'Slutförda',
      'total_tasks': 'Totalt uppgifter',
      'completion': 'Slutförande',
      'total_xp': 'Total XP',
      'account_info': 'Kontoinformation',
      'member_since': 'Medlem sedan',
      'days_active': 'Dagar aktiv',
      'day': 'dag',
      'days': 'dagar',

      // Guest Banner
      'unlock_full_potential': 'Lås upp full potential',
      'create_account_to_save':
          'Skapa ett konto för att spara dina framsteg och aldrig förlora din data',

      // Sign Out Dialog
      'sign_out_title': 'Logga ut',
      'sign_out_message':
          'Är du säker på att du vill logga ut? Din data förblir synkroniserad i molnet.',

      // Plan Screen
      'overview': 'Översikt',
      'week': 'Vecka',
      'month': 'Månad',

      // Features
      'plan_your_days': 'Planera dina dagar med lätthet',
      'earn_xp_level_up': 'Tjäna XP och levla upp',
      'track_your_goals': 'Spåra dina mål',

      // Errors
      'error_loading': 'Fel vid laddning',
      'sign_up_failed': 'Registrering misslyckades',
      'sign_in_failed': 'Inloggning misslyckades',

      // Validation
      'enter_email': 'Vänligen ange din e-post',
      'valid_email': 'Vänligen ange en giltig e-postadress',
      'enter_password': 'Vänligen ange ett lösenord',
      'password_min_length': 'Lösenordet måste vara minst 6 tecken',
      'passwords_no_match': 'Lösenorden matchar inte',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Shorthand getter
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sv'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
