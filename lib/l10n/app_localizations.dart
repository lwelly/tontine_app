import 'dart:async';
import 'package:flutter/material.dart';
class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  bool get _isFr => locale.languageCode == 'fr';

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? _instance;

  static Future<AppLocalizations> load(Locale locale) async {
    _instance = AppLocalizations(locale);
    return _instance!;
  }
  // Login Screen
  String get loginTitle => _isFr ? 'Connexion' : 'تسجيل الدخول';
  String get emailOrPhone => _isFr ? 'Email ou téléphone' : 'البريد الإلكتروني أو الهاتف';
  String get createAccount => _isFr ? 'Créer un compte' : 'إنشاء حساب';
  String get login => _isFr ? 'Se connecter' : 'دخول';
  String get allUsersEqual => _isFr ? 'Tous les utilisateurs sont égaux' : 'كل المستخدمين متساوون';
  String get loginEmailOrPhoneRequired => _isFr ? 'Veuillez entrer votre email ou téléphone' : 'الرجاء إدخال البريد الإلكتروني أو رقم الهاتف';
  String get passwordLabel => _isFr ? 'Mot de passe' : 'كلمة المرور';
  String get passwordRequired => _isFr ? 'Veuillez entrer le mot de passe' : 'الرجاء إدخال كلمة المرور';
  String get passwordMinLength => _isFr ? 'Le mot de passe doit contenir au moins 6 caractères' : 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  String get fullNameLabel => _isFr ? 'Nom complet' : 'الاسم الكامل';
  String get fullNameRequired => _isFr ? 'Veuillez entrer votre nom complet' : 'الرجاء إدخال الاسم الكامل';
  String get phoneLabel => _isFr ? 'Téléphone' : 'رقم الهاتف';
  String get phoneRequired => _isFr ? 'Veuillez entrer votre numéro de téléphone' : 'الرجاء إدخال رقم الهاتف';
  String get confirmPasswordLabel => _isFr ? 'Confirmer le mot de passe' : 'تأكيد كلمة المرور';
  String get passwordsDoNotMatch => _isFr ? 'Les mots de passe ne correspondent pas' : 'كلمات المرور غير متطابقة';
  String get retry => _isFr ? 'Réessayer' : 'حاول مجدداً';
  String get authInvalidEmail => _isFr ? 'Email invalide' : 'البريد الإلكتروني غير صالح';
  String get authUserDisabled => _isFr ? 'Ce compte est désactivé' : 'تم تعطيل هذا الحساب';
  String get authUserNotFound => _isFr ? 'Aucun compte trouvé' : 'لا يوجد حساب بهذا البريد';
  String get authWrongPassword => _isFr ? 'Mot de passe incorrect' : 'كلمة المرور غير صحيحة';
  String get authEmailAlreadyInUse => _isFr ? 'Cet email est déjà utilisé. Connectez-vous à la place' : 'هذا البريد مُستخدم بالفعل. سجّل دخولك بدلاً من ذلك';
  String get authWeakPassword => _isFr ? 'Mot de passe faible. Utilisez au moins 6 caractères' : 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل';
  String get authNetworkError => _isFr ? 'Erreur de connexion. Vérifiez Internet et réessayez' : 'خطأ في الاتصال. تحقق من الإنترنت وحاول مجدداً';
  String get registrationSuccessTitle => _isFr ? 'Compte créé' : 'تم إنشاء الحساب';
  String get registrationVerifyEmailAndLogin => _isFr ? 'Vérifiez votre email puis connectez-vous.' : 'تحقق من بريدك الإلكتروني ثم سجّل الدخول.';
  // Home/Dashboard Screen
  String get homeTitle => _isFr ? '🏠 Accueil' : '🏠 الشاشة الرئيسية';
  String get welcome => _isFr ? 'Bienvenue 👋' : 'مرحباً بك 👋';
  String get homeSubtitle => _isFr ? 'Organisation transparente de la tontine' : 'تنظيم شفاف للتونتين';
  String get navHome => _isFr ? 'Accueil' : 'الرئيسية';
  String get navCreateGroup => _isFr ? 'Créer un groupe' : 'إضافة مجموعة';
  String get navSettings => _isFr ? 'Paramètres' : 'الإعدادات';
  String get navProfile => _isFr ? 'Profil' : 'Profile';
  String get groupGeneric => _isFr ? 'Groupe' : 'مجموعة';
  String get allGroups => _isFr ? 'Tous les groupes' : 'كل المجموعات';
  String get totalPaymentsFiltered => _isFr ? 'Total des paiements (filtre)' : 'إجمالي المدفوعات (حسب الفلتر)';
  String get monthLabel => _isFr ? 'Mois' : 'الشهر';
  String get dateLabel => _isFr ? 'Date' : 'التاريخ';
  String get noData => _isFr ? 'Aucune donnée' : 'لا توجد بيانات';
  String get loginToSeeJoinRequests => _isFr ? 'Connectez-vous pour voir les demandes' : 'سجّل الدخول لعرض طلبات الانضمام';
  String get noJoinRequests => _isFr ? 'Aucune demande' : 'لا توجد طلبات انضمام';
  String get joinRequestsWillAppearHere => _isFr ? 'Les demandes apparaîtront ici' : 'ستظهر هنا طلبات الانضمام إلى مجموعاتك';
  String get byGroup => _isFr ? 'Par groupe' : 'حسب المجموعة';
  String pendingRequestsCount(int count) => _isFr ? '$count demande(s) en attente' : '$count طلب(ات) معلّقة';
  String get featureNotAvailableYet => _isFr ? 'Cette fonctionnalité n\'est pas encore disponible' : 'تم حذف شاشة تفاصيل الطلبات من لوحة التحكم';
  String get latestRequests => _isFr ? 'Dernières demandes' : 'أحدث الطلبات';
  String get requestDateLabel => _isFr ? 'Date de demande' : 'تاريخ الطلب';
  String get openGroupRequestsTooltip => _isFr ? 'Ouvrir les demandes de ce groupe' : 'فتح طلبات هذه المجموعة';
  String get requestApproved => _isFr ? 'Demande approuvée' : 'تم قبول الطلب بنجاح';
  String get requestRejected => _isFr ? 'Demande rejetée' : 'تم رفض الطلب';
  String get accept => _isFr ? 'Accepter' : 'قبول';
  String get reject => _isFr ? 'Refuser' : 'رفض';
  String get noGroups => _isFr ? 'Aucun groupe' : 'لا توجد مجموعات';
  String get noGroupsMySubtitle => _isFr ? 'Créez un groupe ou rejoignez-en un depuis l\'onglet (Tous)' : 'أنشئ مجموعة أو انضم لمجموعة من تبويب (الكل)';
  String get noGroupsPublicSubtitle => _isFr ? 'Les groupes publics apparaîtront ici' : 'ستظهر المجموعات العامة هنا';
  String membersCount(int count) => _isFr ? '$count membre(s)' : '$count عضو';
  String get joinRequestSent => _isFr ? 'Demande d\'adhésion envoyée' : 'تم إرسال طلب الانضمام';
  String get myGroupBadge => _isFr ? 'Mon groupe' : 'مجموعتي';
  String get memberBadge => _isFr ? 'Membre' : 'عضو';
  String get joinBadge => _isFr ? 'Rejoindre' : 'انضمام';
  String get myGroups => _isFr ? 'Mes groupes' : 'مجموعاتي';
  String get otherGroups => _isFr ? 'Autres groupes' : 'مجموعات أخرى';
  String get latestPayment => _isFr ? 'Dernier paiement' : 'آخر دفعة';
  String get loginToSeeLatestPayment => _isFr ? 'Connectez-vous pour voir le dernier paiement' : 'سجّل الدخول لعرض آخر دفعة';
  String get noPaymentsYet => _isFr ? 'Aucun paiement pour le moment' : 'لا توجد دفعات بعد';
  String get notEnoughData => _isFr ? 'Données insuffisantes' : 'لا توجد بيانات كافية';
  String get dashboardTitle => _isFr ? 'Tableau de bord' : 'لوحة التحكم';
  String get all => _isFr ? 'Tous' : 'الكل';
  String get requests => _isFr ? 'Demandes' : 'طلبات';
  String get totalPaid => _isFr ? 'Total payé' : 'مجموع ما دفعت';
  String get nextTurn => _isFr ? 'Mon prochain tour' : 'دوري القادم';
  String get generalNotifications => _isFr ? 'Notifications générales' : 'تنبيهات عامة';
  // Tontine Groups Screen
  String get groupsTitle => _isFr ? '👥 Groupes de tontine' : '👥 مجموعات التونتين';
  String get groupName => _isFr ? 'Nom' : 'الاسم';
  String get amount => _isFr ? 'Montant' : 'المبلغ';
  String get members => _isFr ? 'Membres' : 'الأعضاء';
  String get status => _isFr ? 'Statut' : 'الحالة';
  String get myGroupsTabTitle => _isFr ? 'Mes groupes' : 'مجموعاتي';
  String get allGroupsTabTitle => _isFr ? 'Tous les groupes' : 'جميع المجموعات';
  String get createGroupFab => _isFr ? 'Créer un groupe' : 'إنشاء مجموعة';
  String get firestoreErrorTitle => _isFr ? 'Erreur Firestore' : 'خطأ في Firestore';
  String get noTontineGroupsTitle => _isFr ? 'Aucun groupe de tontine' : 'لا توجد مجموعات تونتين';
  String get noTontineGroupsSubtitle => _isFr ? 'Commencez par créer un nouveau groupe' : 'ابدأ بإنشاء مجموعة جديدة';
  String get noAvailableGroupsTitle => _isFr ? 'Aucun groupe disponible' : 'لا توجد مجموعات متاحة';
  String get noAvailableGroupsSubtitle => _isFr ? 'Soyez le premier à créer un groupe public' : 'كن أول من ينشئ مجموعة عامة';
  String get unnamedGroup => _isFr ? 'Groupe sans nom' : 'مجموعة غير مسماة';
  String get pendingRequest => _isFr ? 'Demande en attente' : 'طلب معلق';
  String get joinRequestAction => _isFr ? 'Demander à rejoindre' : 'طلب الانضمام';
  String get statusActive => _isFr ? 'Active' : 'نشطة';
  String get statusCompleted => _isFr ? 'Terminée' : 'مكتملة';
  String get statusPaused => _isFr ? 'En pause' : 'متوقفة';
  String get statusUnknown => _isFr ? 'Inconnue' : 'غير معروفة';
  // Group Details Screen
  String get groupDetailsTitle => _isFr ? '📌 Détails du groupe' : '📌 تفاصيل المجموعة';
  String get groupNotFound => _isFr ? 'Groupe introuvable' : 'المجموعة غير موجودة';
  String turnOfTotal(int turn, int total) => _isFr ? 'Tour $turn sur $total' : 'الدور $turn من $total';
  String get paymentActionSubtitle => _isFr ? 'Voir / enregistrer le paiement' : 'عرض / تسجيل الدفع';
  String get joinRequestsTitle => _isFr ? 'Demandes d\'adhésion' : 'طلبات الانضمام';
  String get joinRequestsSubtitle => _isFr ? 'Examiner les demandes reçues' : 'مراجعة الطلبات الواردة';
  String drawForMonth(String currentMonth) => _isFr ? 'Effectuer le tirage pour $currentMonth' : 'إجراء القرعة للشهر $currentMonth';
  String get waitingAllMembersToPay => _isFr ? 'En attente du paiement de tous les membres' : 'بانتظار دفع جميع الأعضاء';
  String get creatorOnly => _isFr ? 'Disponible uniquement pour le créateur' : 'متاح لمنشئ المجموعة فقط';
  String get drawCreatorOnlySnackbar => _isFr ? 'Le tirage est réservé au créateur du groupe' : 'القرعة متاحة لمنشئ المجموعة فقط';
  String get drawRequiresAllPaidSnackbar => _isFr ? 'Impossible de tirer avant que tous les membres aient payé ce mois-ci' : 'لا يمكن إجراء القرعة قبل دفع جميع الأعضاء لهذا الشهر';
  String get paymentStatusThisMonthTitle => _isFr ? 'Statut de paiement du mois' : 'حالة الدفع لهذا الشهر';
  String paidCountOfTotal(int paid, int total) => _isFr ? '$paid / $total ont payé' : '$paid / $total قاموا بالدفع';
  String get allMembersPaidThisMonth => _isFr ? 'Tous les membres ont payé ce mois-ci' : 'جميع الأعضاء دفعوا لهذا الشهر';
  String get loadingUnpaidMembers => _isFr ? 'Chargement des membres en retard de paiement...' : 'جاري تحميل المتأخرين عن الدفع...';
  String get unpaidMembersTitle => _isFr ? 'N\'a pas encore payé :' : 'لم يدفع بعد:';
  String plusOthers(int count) => _isFr ? '+ $count autres' : '+ $count آخرين';
  String unresolvedMembersCount(int count) => _isFr ? 'Impossible de charger les données de $count membre(s)' : 'تعذر تحميل بيانات $count عضو';
  String get tontineInfo => _isFr ? 'Informations de la tontine' : 'معلومات التونتين';
  String get allMembers => _isFr ? 'Tous les membres' : 'كل الأعضاء';
  String get whoPaid => _isFr ? 'Qui a payé / qui n\'a pas payé' : 'من دفع ومن لا';
  String get currentAndNextTurn => _isFr ? 'Tour actuel et prochain' : 'الدور الحالي والقادم';
  // Payment Screen
  String get paymentTitle => _isFr ? '💳 Paiement' : '💳 الدفع';
  String get paymentNotification => _isFr ? 'Notification de paiement' : 'إشعار بالدفع';
  String get amountDueLabel => _isFr ? 'Montant dû' : 'المبلغ المستحق';
  String get payButton => _isFr ? 'Payer' : 'زر دفع';
  String get liveStatusUpdate => _isFr ? 'Mise à jour en direct' : 'تحديث مباشر للحالة';
  String get paymentRequired => _isFr ? 'Le système bloque si le paiement n\'est pas complet' : 'النظام يمنع التقدم إذا لم يكتمل الدفع';
  String get mustBeMemberToPayTitle => _isFr ? 'Vous devez être membre du groupe pour payer' : 'يجب أن تكون عضوًا في المجموعة للدفع';
  String get mustJoinGroupFirstSubtitle => _isFr ? 'Rejoignez d\'abord le groupe puis réessayez' : 'انضم إلى المجموعة أولاً ثم حاول الدفع مرة أخرى';
  String get goBack => _isFr ? 'Retour' : 'العودة';
  String get alreadyPaidThisMonth => _isFr ? 'Paiement déjà effectué pour ce mois' : 'تم الدفع لهذا الشهر مسبقاً';
  String get paymentSuccessWithNotification => _isFr ? 'Paiement réussi ! Une notification de confirmation a été envoyée.' : 'تم الدفع بنجاح! تم إرسال إشعار التأكيد.';
  String get paymentsEmptyTitle => _isFr ? 'Aucun paiement enregistré' : 'لا توجد مدفوعات مسجلة';
  String get paidBadge => _isFr ? 'Payé' : 'مدفوع';
  String get amountLabel => _isFr ? 'Montant' : 'المبلغ';
  String get monthLabelShort => _isFr ? 'Mois' : 'الشهر';
  String get dateLabelShort => _isFr ? 'Date' : 'التاريخ';
  String paymentError(String message) => _isFr ? 'Erreur : $message' : 'حدث خطأ: $message';
  // Create Group Screen
  String get createGroupTitle => _isFr ? 'Créer un nouveau groupe' : 'إنشاء مجموعة جديدة';
  String get groupNameLabel => _isFr ? 'Nom du groupe' : 'اسم المجموعة';
  String get monthlyAmountLabel => _isFr ? 'Montant mensuel (MRU)' : 'المبلغ الشهري (MRU)';
  String get fieldRequired => _isFr ? 'Ce champ est requis' : 'هذا الحقل مطلوب';
  String get enterValidAmount => _isFr ? 'Entrez un montant valide' : 'أدخل مبلغاً صحيحاً';
  String get createGroupAction => _isFr ? 'Créer le groupe' : 'إنشاء المجموعة';
  String get creatingGroup => _isFr ? 'Création...' : 'جاري الإنشاء...';
  String get groupCreatedSuccess => _isFr ? 'Groupe créé avec succès' : 'تم إنشاء المجموعة بنجاح';
  // Draw/Lottery Screen
  String get drawTitle => _isFr ? '🎲 Tirage / Tour' : '🎲 القرعة / الدور';
  String get automaticDraw => _isFr ? 'Le tirage est automatique' : 'القرعة تتم تلقائيًا';
  String get showResult => _isFr ? 'Le résultat est visible pour tous' : 'تظهر النتيجة للجميع';
  String get noManualControl => _isFr ? 'Aucun contrôle manuel' : 'لا زر تحكم يدوي';
  String get algorithmBased => _isFr ? 'Basé uniquement sur un algorithme' : 'تعتمد على خوارزمية فقط';
  String get drawRequiresAllPaidBeforeStart => _isFr ? 'Tous les membres doivent payer d\'abord' : 'يجب أن يدفع جميع الأعضاء أولاً';
  String get drawSuccess => _isFr ? 'Tirage effectué avec succès' : 'تمت القرعة بنجاح';
  String get noBeneficiaryYetTitle => _isFr ? 'Aucun bénéficiaire sélectionné' : 'لم يتم اختيار مستفيد بعد';
  String get noBeneficiaryYetSubtitle => _isFr ? 'Appuyez sur le bouton de tirage ci-dessous' : 'اضغط على زر القرعة أدناه';
  String get beneficiaryThisMonthTitle => _isFr ? 'Bénéficiaire du mois' : 'المستفيد لهذا الشهر';
  String get memberGeneric => _isFr ? 'Membre' : 'عضو';
  String get noWinnersYet => _isFr ? 'Aucun gagnant pour le moment' : 'لا يوجد فائزين بعد';
  String get winnerBadge => _isFr ? 'Gagnant' : 'فائز';
  String get accessRestrictedTitle => _isFr ? 'Accès restreint' : 'الوصول مقيد';
  String get waitingForPaymentTitle => _isFr ? 'En attente de paiement' : 'في انتظار الدفع';
  String get currentTabTitle => _isFr ? 'Actuel' : 'الحالي';
  String get allTabTitle => _isFr ? 'Tous' : 'الكل';
  String get automaticDrawTitle => _isFr ? 'Tirage automatique' : 'القرعة التلقائية';
  String get fairTurnSystemSubtitle => _isFr ? 'Système de tour équitable' : 'نظام دوري عادل';
  String get startDrawAction => _isFr ? 'Démarrer le tirage' : 'ابدأ القرعة';
  // Notifications Screen
  String get notificationsTitle => _isFr ? '🔔 Notifications' : '🔔 الإشعارات';
  String get newBadge => _isFr ? 'Nouveau' : 'جديد';
  String get markAllAsRead => _isFr ? 'Marquer tout comme lu' : 'تحديد الكل كمقروء';
  String get unableToMarkAllAsRead => _isFr ? 'Impossible de tout marquer comme lu' : 'تعذر تحديد الكل كمقروء';
  String get failedToLoadNotifications => _isFr ? 'Impossible de charger les notifications' : 'تعذر تحميل الإشعارات';
  String get noNotifications => _isFr ? 'Aucune notification' : 'لا توجد إشعارات';
  String get notificationGeneric => _isFr ? 'Notification' : 'إشعار';
  String get paymentConfirmationTitle => _isFr ? 'Confirmation de paiement' : 'تأكيد الدفع';
  String get newMemberTitle => _isFr ? 'Nouveau membre' : 'عضو جديد';
  String get memberLeftTitle => _isFr ? 'Membre parti' : 'غادر عضو';
  String get joinRequestTitle => _isFr ? 'Demande d\'adhésion' : 'طلب انضمام';
  String get joinApprovedTitle => _isFr ? 'Adhésion approuvée' : 'تم قبول الانضمام';
  String get joinRejectedTitle => _isFr ? 'Adhésion refusée' : 'تم رفض الانضمام';
  String paymentConfirmationMessage(String amount, String groupName, String month) =>
      _isFr
          ? 'Votre paiement pour "$groupName" ($month) a été confirmé : $amount MRU.'
          : 'تم تأكيد دفعتك لمجموعة "$groupName" بمبلغ $amount MRU للشهر $month.';
  String get joinRequestMessage => _isFr ? 'Nouvelle demande pour rejoindre votre groupe' : 'طلب جديد للانضمام إلى مجموعتك';
  String get joinApprovedMessage => _isFr ? 'Votre demande d\'adhésion a été approuvée' : 'تم قبول طلب انضمامك للمجموعة';
  String get joinRejectedMessage => _isFr ? 'Votre demande d\'adhésion a été refusée' : 'تم رفض طلب انضمامك للمجموعة';
  String get memberLeftMessage => _isFr ? 'Un membre a quitté votre groupe' : 'غادر عضو مجموعتك';
  String get now => _isFr ? 'Maintenant' : 'الآن';
  String minutesAgo(int minutes) => _isFr ? 'il y a $minutes min' : 'منذ $minutes دقيقة';
  String hoursAgo(int hours) => _isFr ? 'il y a $hours h' : 'منذ $hours ساعة';
  String daysAgo(int days) => _isFr ? 'il y a $days j' : 'منذ $days يوم';
  String get yesterday => _isFr ? 'Hier' : 'أمس';
  String get paymentDue => _isFr ? 'Échéance de paiement' : 'موعد الدفع';
  String get beneficiaryAnnouncement => _isFr ? 'Annonce du bénéficiaire' : 'إعلان المستفيد';
  String get paymentDelay => _isFr ? 'Retard de paiement' : 'تأخير الدفع';
  String get sentToAll => _isFr ? 'Envoyé à tout le monde' : 'ترسل للجميع بدون استثناء';
  // Settings Screen
  String get settingsTitle => _isFr ? '⚙️ Paramètres' : '⚙️ الإعدادات';
  String get editAccount => _isFr ? 'Modifier le compte' : 'تعديل الحساب';
  String get language => _isFr ? 'Langue' : 'اللغة';
  String get logout => _isFr ? 'Déconnexion' : 'تسجيل الخروج';
  String get noGroupSettings => _isFr ? 'Pas de paramètres de groupe' : 'لا إعدادات مجموعة';

  String get logoutConfirm => _isFr ? 'Êtes-vous sûr de vouloir vous déconnecter ?' : 'هل أنت متأكد من تسجيل الخروج؟';
  String get logoutSubtitle => _isFr ? 'Se déconnecter de l\'application' : 'تسجيل الخروج من التطبيق';
  String get editProfileTitle => _isFr ? 'Modifier le profil' : 'تعديل الملف الشخصي';
  String get nameLabel => _isFr ? 'Nom' : 'الاسم';
  String get emailLabel => _isFr ? 'Email' : 'البريد الإلكتروني';
  String get changesSaved => _isFr ? 'Modifications enregistrées' : 'تم حفظ التغييرات';
  String get editAccountSubtitle => _isFr ? 'Modifier vos informations personnelles' : 'تعديل معلوماتك الشخصية';
  String get changeLanguageSubtitle => _isFr ? 'Changer la langue de l\'application' : 'تغيير لغة التطبيق';
  String get aboutAppTitle => _isFr ? 'À propos' : 'حول التطبيق';
  String get aboutAppVersion => _isFr ? 'Version 1.0.0' : 'الإصدار 1.0.0';
  String get aboutAppName => _isFr ? 'Application Tontine Transparente' : 'تطبيق التونتين الشفاف';
  String get aboutAppDescription => _isFr ? 'Organisation de tontine sans gestion centrale' : 'تنظيم تونتين بدون إدارة مركزية';
  String get ok => _isFr ? 'OK' : 'موافق';
  String get languageArabicTitle => _isFr ? 'Arabe' : 'العربية';
  String get languageArabicSubtitle => _isFr ? 'العربية' : 'العربية';
  String get languageFrenchTitle => _isFr ? 'Français' : 'Français';
  String get languageFrenchSubtitle => _isFr ? 'Français' : 'الفرنسية';
  // Profile Screen
  String get profileTitle => _isFr ? 'Profil' : 'الملف الشخصي';
  String get userGeneric => _isFr ? 'Utilisateur' : 'المستخدم';
  String get notLoggedIn => _isFr ? 'Non connecté' : 'غير مسجل الدخول';
  String get loginToAccessFeaturesTitle => _isFr ? 'Connectez-vous' : 'سجّل الدخول';
  String get loginToAccessFeaturesSubtitle => _isFr ? 'Pour accéder à toutes les fonctionnalités du compte.' : 'للوصول إلى جميع ميزات الحساب.';
  String get accountReadyTitle => _isFr ? 'Votre compte est prêt' : 'حسابك جاهز';
  String get accountReadySubtitle => _isFr ? 'Vous pouvez gérer vos groupes dans l\'application.' : 'يمكنك إدارة مجموعاتك من داخل التطبيق.';
  // My Payments Screen
  String get myPaymentsTitle => _isFr ? 'Historique de mes paiements' : 'سجل دفعاتي';
  String get loginToViewPaymentsHistory => _isFr ? 'Connectez-vous pour voir votre historique de paiements' : 'لا يمكن عرض سجل الدفعات بدون تسجيل الدخول';
  String get paymentsHistoryLoadFailed => _isFr ? 'Impossible de charger l\'historique des paiements' : 'تعذر تحميل سجل الدفعات';
  String get paymentsWillAppearHere => _isFr ? 'Une fois vos paiements effectués, ils apparaîtront ici automatiquement' : 'عند إجراء دفعات ستظهر هنا تلقائياً';
  // My Requests Screen
  String get myJoinRequestsTitle => _isFr ? 'Mes demandes d\'adhésion' : 'طلبات الانضمام الخاصة بي';
  String get myJoinRequestsEmptySubtitle => _isFr ? 'Demandez à rejoindre des groupes et attendez l\'approbation' : 'اطلب الانضمام إلى المجموعات وانتظر الموافقة';
  String get myJoinRequestsHint => _isFr ? 'Vous serez notifié lorsque votre demande est acceptée ou refusée' : 'سيتم إشعارك عند قبول أو رفض طلبك';
  // Common
  String get loading => _isFr ? 'Chargement...' : 'جاري التحميل...';
  String get error => _isFr ? 'Erreur' : 'خطأ';
  String get success => _isFr ? 'Succès' : 'نجاح';
  String get cancel => _isFr ? 'Annuler' : 'إلغاء';
  String get confirm => _isFr ? 'Confirmer' : 'تأكيد';
  String get back => _isFr ? 'Retour' : 'رجوع';
  String get next => _isFr ? 'Suivant' : 'التالي';
  String get save => _isFr ? 'Enregistrer' : 'حفظ';
  String get delete => _isFr ? 'Supprimer' : 'حذف';
  String get edit => _isFr ? 'Modifier' : 'تعديل';
  String get add => _isFr ? 'Ajouter' : 'إضافة';
  String get search => _isFr ? 'Rechercher' : 'بحث';
  String get filter => _isFr ? 'Filtrer' : 'تصفية';
  String get refresh => _isFr ? 'Actualiser' : 'تحديث';
  String get close => _isFr ? 'Fermer' : 'إغلاق';
}
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en', 'fr'].contains(locale.languageCode);
  }
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.load(locale);
  }
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
