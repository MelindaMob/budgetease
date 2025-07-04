# flutter_application_1

## PRESENTATION DU PROJET ##

BudgetEase – Application mobile de gestion de budget personnel
# Objectif du projet
L’objectif du projet BudgetEase est de concevoir une application mobile intuitive permettant aux utilisateurs de gérer leurs finances personnelles. L’application vise à simplifier le suivi des revenus et des dépenses, tout en offrant une vue claire et synthétique de la situation financière actuelle de l’utilisateur. Elle s’adresse principalement à des étudiants, jeunes actifs ou toute personne cherchant un outil simple pour contrôler son budget au quotidien.

# Pourquoi ce projet ?
La gestion du budget est une compétence essentielle dans la vie quotidienne, et pourtant peu de solutions sont accessibles, pédagogiques et adaptées à un usage mobile simplifié.
BudgetEase répond à ce besoin en offrant une solution pratique, fonctionnelle et visuellement claire.

# Technologies utilisées
Flutter : Framework de développement mobile multi-plateformes (Android & iOS)
Firebase : Backend-as-a-Service pour la base de données et les opérations en temps réel
Firestore (base de données NoSQL)
fl_chart : Pour la visualisation de données sous forme de graphiques

# Fonctionnalités de l’application
Tableau de bord
Solde total actuel (revenus - dépenses)
Total des revenus
Total des dépenses
Navigation vers les autres fonctionnalités
Ajout d’une transaction
Nom (ex : “Factures”, “Courses”)
Montant
Type (revenu ou dépense)
Catégorie (logement, alimentation, transport, etc.)
Date (via date picker)
Liste des transactions
Affichage chronologique
Détails : titre, montant, date, catégorie
Statistiques
Graphique en camembert : répartition des dépenses par catégorie


## INSTALLATION ##
Récupérer le projet via Github
Installer les dépendences nécessaires
Être ajouté à la base de données Firebase par l'un des utilisateurs


## POST MORTEM ##

# Ce qui a bien fonctionné
-  Fonctionnalités principales opérationnelles
Nous avons réussi à développer les fonctionnalités essentielles de l’application : ajouter une transaction, l’enregistrer dans Firebase, calculer automatiquement le solde, et afficher la liste des revenus et dépenses.

-  Ajout de l’authentification utilisateur
Nous avons intégré Firebase Auth pour permettre la création de compte et la connexion des utilisateurs.
Cela permet en théorie d’isoler les données de chaque utilisateur.

-  Structure de projet claire et modulaire
Nous avons organisé le projet Flutter avec une structure propre (écrans, widgets, services, modèles), ce qui nous a facilité la lecture, la compréhension et la maintenance du code.

-  Progression technique
Ce projet nous a permis de monter en compétence sur Flutter, Firestore, la navigation, les formulaires, la gestion d’état simple, et les appels backend.

# ⚠ Ce qui a posé problème

-  Difficultés avec Firebase
L’intégration avec Firebase a été plus complexe que prévu. Nous avons rencontré :
des problèmes liés aux règles de sécurité de Firestore, des erreurs de permissions, des soucis de synchronisation des données,
et des logs difficiles à interpréter.

-  Bug critique : données non persistées après reconnexion
Après avoir mis en place l’authentification, nous avons constaté un bug important :
lorsque l’utilisateur se déconnecte puis se reconnecte, ses anciennes transactions ne s’affichent plus.
Cela indique que les transactions ne sont pas correctement liées à l’utilisateur connecté, ou que les requêtes ne filtrent pas les données selon le bon userId.

-  Manque de gestion d’erreurs et de feedback utilisateur
Nous n’avons pas encore intégré de messages d’erreur ou de confirmation visibles en cas d’échec ou de succès lors de la connexion ou de l’ajout d’une transaction.

# Ce que nous aurions fait autrement

- Filtrer correctement les données Firestore en fonction de l’utilisateur connecté.
-  Étudier en profondeur les règles de sécurité Firebase avant de coder.
-  Mettre en place une gestion d’état centralisée plus solide (ex. Provider).

# Ce que nous avons appris

-  Connecter Flutter à Firebase est puissant, mais cela demande rigueur, patience et une bonne compréhension des systèmes de sécurité, des relations entre les utilisateurs et les données, et du backend en général.
-  Un projet complet, même avec des bugs, reste une expérience très formatrice. Il nous a permis d’apprendre à organiser notre code, chercher des solutions à des erreurs réelles, et structurer une app fonctionnelle.
-  Nous avons aussi compris l’importance de commencer simple et de solidifier chaque étape avant d’enchaîner sur des fonctionnalités avancées.

# Bilan final
Même si l’application n’est pas encore totalement stable, elle remplit ses objectifs pédagogiques principaux :
construire une app mobile complète avec une interface claire,
intégrer un backend (Firebase),
comprendre la logique des données dynamiques et des utilisateurs.

Nous sommes fiers du chemin parcouru, des obstacles que nous avons dépassés, et des connaissances acquises tout au long de ce projet. Il s’agit d’une base solide pour une version future plus stable et sécurisée.
