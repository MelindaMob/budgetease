```
package "Gestion du compte" {
  Utilisateur --> (Créer un compte)
  Utilisateur --> (Se connecter)
  Utilisateur --> (Se déconnecter)
  Utilisateur --> (Modifier profil)
}

package "Transactions" {
  Utilisateur --> (Ajouter une transaction)
  (Ajouter une transaction) --> (Ajouter une dépense) : <<include>>
  (Ajouter une transaction) --> (Ajouter un gain) : <<include>>
  Utilisateur --> (Modifier ou supprimer une transaction)
  Utilisateur --> (Voir l’historique des transactions)
}

package "Analyse" {
  Utilisateur --> (Voir dépenses totales)
  Utilisateur --> (Voir gains totaux)
  Utilisateur --> (Voir solde total)
  (Voir solde total) --> (Voir dépenses totales) : <<include>>
  (Voir solde total) --> (Voir gains totaux) : <<include>>
}

package "Objectifs d’épargne" {
  Utilisateur --> (Définir un objectif)
  Utilisateur --> (Voir total économisé)
  Utilisateur --> (Supprimer un objectif)
  Utilisateur --> (Objectif atteint) : <<extend>>
}
```
