// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'OrderPulse';

  @override
  String get loginSubtitle => 'Opérations terrain livreur';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get newDriverPrompt => 'Nouveau livreur ? ';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get enterValidEmail => 'Entrez une adresse e-mail valide';

  @override
  String get minSixCharacters => '6 caractères minimum';

  @override
  String get languageLabel => 'Langue';

  @override
  String get langEnglish => 'English';

  @override
  String get langArabic => 'العربية';

  @override
  String get langFrench => 'Français';

  @override
  String get nameLabel => 'Nom complet';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get registerTitle => 'Créez votre compte livreur';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get haveAccountPrompt => 'Vous avez déjà un compte ? ';

  @override
  String get signInInstead => 'Se connecter';

  @override
  String get runSheetTab => 'Tournée';

  @override
  String get cashTab => 'Espèces';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get settingsTooltip => 'Paramètres';

  @override
  String get driverRoleLabel => 'Livreur';

  @override
  String get merchantRoleLabel => 'Commerçant';

  @override
  String get logoutConfirmTitle => 'Se déconnecter ?';

  @override
  String get logoutConfirmBody =>
      'Vous devrez vous reconnecter pour accéder à votre tournée.';

  @override
  String get cancel => 'Annuler';

  @override
  String welcomeBackToast(Object name) {
    return 'Bon retour, $name';
  }

  @override
  String get signedOutToast => 'Déconnecté avec succès.';

  @override
  String get remainingStops => 'Arrêts restants';

  @override
  String get cashCollected => 'Espèces encaissées';

  @override
  String get sectionAwaitingVerification => 'EN ATTENTE DE VÉRIFICATION';

  @override
  String get sectionActiveRun => 'TOURNÉE ACTIVE';

  @override
  String get sectionUpcoming => 'À VENIR';

  @override
  String get sectionDelivered => 'LIVRÉS';

  @override
  String get sectionReturned => 'RETOURNÉS';

  @override
  String get noCallYetBadge => 'AUCUN APPEL';

  @override
  String get customerSection => 'Client';

  @override
  String get financialsSection => 'Finances';

  @override
  String get itemSubtotal => 'Sous-total articles';

  @override
  String get shippingFee => 'Frais de livraison';

  @override
  String get totalCod => 'Total COD (contre remboursement)';

  @override
  String get collectedByDriver => 'Encaissé par le livreur';

  @override
  String get codPanelTitle => 'MONTANT À ENCAISSER À LA LIVRAISON';

  @override
  String get attemptAuditTrail => 'Journal de la tentative';

  @override
  String get reasonRow => 'Motif';

  @override
  String get callInitiatedRow => 'Appel initié';

  @override
  String get callDurationRow => 'Durée de l\'appel';

  @override
  String get gpsFixRow => 'Position GPS';

  @override
  String get accuracyRadiusRow => 'Rayon de précision';

  @override
  String get merchantIntervenedRow => 'Intervention du commerçant';

  @override
  String get yes => 'OUI';

  @override
  String get no => 'NON';

  @override
  String get unverifiedFlagRow => 'RETOUR NON VÉRIFIÉ';

  @override
  String get attemptedCallsRow => 'Appels effectués';

  @override
  String get responseTimerTitle => 'SIGNALEZ LE RÉSULTAT DANS';

  @override
  String get responseTimerBody =>
      'Le commerçant attend votre résultat de livraison. Signalez Livré ou Échec avant la fin du minuteur.';

  @override
  String get responseTimerExpiredChip => 'PAS DE RÉPONSE';

  @override
  String get verificationWindowClosed => 'FENÊTRE DE VÉRIFICATION FERMÉE';

  @override
  String get windowClosedMessage =>
      'Aucune intervention du commerçant. Cette commande peut maintenant être traitée comme retournée.';

  @override
  String get merchantVerification => 'VÉRIFICATION COMMERÇANT';

  @override
  String get merchantAlertedText =>
      'Le commerçant a été alerté et peut annuler cet échec avant la fin du minuteur.';

  @override
  String get actionCallCustomer => '1. Appeler le client';

  @override
  String get actionDelivered => 'Livré';

  @override
  String get actionFailed => 'Échec';

  @override
  String get reportFailedAttemptTitle => 'Signaler un échec de livraison';

  @override
  String get auditNotice =>
      'Votre position GPS et la preuve d\'appel seront jointes au journal d\'audit.';

  @override
  String get reasonUnresponsive => 'Client injoignable';

  @override
  String get reasonRefused => 'Client ayant refusé la livraison';

  @override
  String get reasonWrongAddress => 'Adresse erronée / inaccessible';

  @override
  String get unverifiedDialogTitle => 'Retourner sans appeler ?';

  @override
  String get unverifiedDialogBody =>
      'Aucun appel vérifié n\'a été trouvé sur cet appareil. Le retour sera signalé comme NON VÉRIFIÉ, le commerçant sera alerté immédiatement, et votre score de confiance pourrait être réduit si le client conteste.';

  @override
  String get returnAnyway => 'Retourner quand même';

  @override
  String get errorDialerFailed => 'Impossible d\'ouvrir le clavier d\'appel.';

  @override
  String get errorGpsFailed =>
      'Position indisponible. Activez la localisation puis réessayez.';

  @override
  String get errorGenericAction =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get merchantShellTitle => 'Console commerçant';

  @override
  String get merchantSubtitle => 'Vérifications en attente';

  @override
  String get noPendingVerifications =>
      'Aucune commande en attente de vérification.';

  @override
  String get confirmFailureButton => 'Confirmer l\'échec';

  @override
  String get overrideButton => 'Annuler → re-dispatcher';

  @override
  String get overrideNoteHint =>
      'Note (optionnel) : ex. client rappelé, veut le produit';

  @override
  String get unverifiedBadge => 'NON VÉRIFIÉ';

  @override
  String get trustScoreLabel => 'Score de confiance';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get accountSection => 'Compte';

  @override
  String get saveProfile => 'Enregistrer le profil';

  @override
  String get profileSavedToast => 'Profil mis à jour.';

  @override
  String get timersSection => 'Minuteurs opérationnels';

  @override
  String get driverTimerLabel => 'Délai de réponse livreur (après appel)';

  @override
  String get merchantTimerLabel =>
      'Délai de vérification commerçant (après échec)';

  @override
  String minutesUnit(Object n) {
    return '$n min';
  }

  @override
  String get timerSavedToast => 'Minuteurs mis à jour.';

  @override
  String get statusPending => 'EN ATTENTE';

  @override
  String get statusConfirmed => 'CONFIRMÉE';

  @override
  String get statusDispatched => 'EXPÉDIÉE';

  @override
  String get statusOutForDelivery => 'EN LIVRAISON';

  @override
  String get statusDeliveredPaid => 'LIVRÉ & PAYÉ';

  @override
  String get statusPendingVerification => 'VÉRIF. EN COURS';

  @override
  String get statusReturned => 'RETOURNÉ';

  @override
  String get todayLabel => 'AUJOURD\'HUI';

  @override
  String get cashInHandNote => 'Espèces à remettre au dépôt';

  @override
  String nDelivered(Object n) {
    return '$n livrées';
  }

  @override
  String nFailedReturned(Object n) {
    return '$n échecs/retours';
  }

  @override
  String get settlementSubmittedToday =>
      'La clôture du jour a déjà été soumise';

  @override
  String get submitSettlement => 'Soumettre la clôture de fin de journée';

  @override
  String get settlementAwaitingApproval =>
      'Soumise — en attente de validation du responsable.';

  @override
  String get settlementHistory => 'HISTORIQUE DES CLÔTURES';

  @override
  String get noSettlementsYet => 'Aucune clôture pour le moment.';

  @override
  String get statusPendingShort => 'EN ATTENTE';

  @override
  String get statusApprovedShort => 'VALIDÉE';

  @override
  String redispatchToast(Object tracking) {
    return '$tracking re-dispachée au livreur.';
  }

  @override
  String confirmedReturnToast(Object tracking) {
    return '$tracking marquée comme retournée.';
  }
}
