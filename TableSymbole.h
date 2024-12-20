#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/*
===================== Section 1 : La table des symboles des identifiants et variables =====================
*/

typedef struct Element{
    char* nomEntite ;
    char* codeEntite ;
    char* type ;
    int final;
    int valeur;
    int dimension;
    bool is_set;
}Element;

typedef struct Node{
    Element inf;
    struct Node* svt;
}Node;

typedef Node* List;

List TS = NULL;

bool rechercherEntite (List TS , char* nomEntite){
    Node* p = TS;
    while (p != NULL && strcmp(p->inf.nomEntite, nomEntite) != 0) {
    p = p->svt;             //  aller vers le noeud suivant
    }

    if (p == NULL){         //  insertion si la liste est initialement vide
        return false;
    }
    else {
        return true;
    }
}

void insererEntite (List *TS , char* nomEntite ,char* codeEntite){
    if (rechercherEntite(*TS,nomEntite)==false) {
        Node* p = (Node*)malloc(sizeof(Node));      //  creer un noeud 
        p->inf.codeEntite=strdup(codeEntite);
        p->inf.type="";
        p->inf.nomEntite = strdup(nomEntite);
        p->inf.dimension = -1;
        p->inf.final=0;
        p->inf.valeur=-1;
        p->inf.is_set=false;
        p->svt=NULL;
        //      Insertion
        if (*TS == NULL){            //  Cas 1 : La liste ne contient aucun element
            *TS = p;
        }
        else{                       //  Cas 2 : La liste contient au moins 1 element , l'insertion se fait allors à la fin
            Node* head = *TS;
            while (head->svt != NULL){
                head = head->svt;
            }
            head->svt = p;
        }
    }

}

bool set (List TS,char* nomEntite){
    Node* p = TS;
    while ((p!=NULL)&&(strcmp(p->inf.nomEntite,nomEntite)!=0)){
        p=p->svt;
    }
    return p->inf.is_set;
}

void set_it (List TS,char* nomEntite){
    Node* p = TS;
    while ((p!=NULL)&&(strcmp(p->inf.nomEntite,nomEntite)!=0)){
        p=p->svt;
    }
    p->inf.is_set=true;
}

void getType(List TS,char* nomEntite,char* type){       // type est passée en entrée/sortie
    Node* p=TS;
    while ((p!=NULL)&&(strcmp(p->inf.nomEntite,nomEntite)!=0)){
        p=p->svt;           //  parcourir la table pour trouver l'entite en question
    }
    strcpy(type,p->inf.type);       // mettre a jour le type
}

void insererType(List TS , char* nomEntite , char* type){
        Node* p = TS;
        while (strcmp(p->inf.nomEntite,nomEntite)!=0){
            p=p->svt;               //  parcourir la table pour trouver l'entite en question
        }
        p->inf.type=strdup(type);   //  mettre à jour le type
}

void setFinal(List TS,char* nomEntite ){
    Node* p = TS;
    while ((strcmp(nomEntite,p->inf.nomEntite)!=0)&&(p!=NULL)){
        p=p->svt;
    }
    p->inf.final=1;
}   

int getFinal(List TS,char* nomEntite ){
    Node* p = TS;
    while ((strcmp(nomEntite,p->inf.nomEntite)!=0)&&(p!=NULL)){
        p=p->svt;
    }
    return p->inf.final;
}   


void afficherTS (List TS){
    printf("\n_______________________________ LA TABLE DES SYMBOLES ______________________________________________________________________________\n\n");
    printf("Nom Entite\t    |Code Entite\t |Type\t\t      |Dimension\t   |Final\t    |Is set\t    |\t\t    |\n");
    printf("____________________________________________________________________________________________________________________________________\n");
    Node* p = TS;
    while (p != NULL){
        if (strcmp(p->inf.type,"")==0){
            printf ("%-20s|%-20s|/\t\t      |/\t\t   |/\t\t    |/\t\t    |\t\t    |\n",p->inf.nomEntite,p->inf.codeEntite);
        }
        else {
            if (p->inf.final==1)
            printf ("%-20s|%-20s|%-20s|%-20d|%-16d|%-15d|\t\t    |\n",p->inf.nomEntite,p->inf.codeEntite,p->inf.type,p->inf.dimension,p->inf.final,p->inf.is_set);
            else 
            printf ("%-20s|%-20s|%-20s|%-20d|%-16d|/\t\t    |\t\t    |\n",p->inf.nomEntite,p->inf.codeEntite,p->inf.type,p->inf.dimension,p->inf.final);
        }
        printf("____________________________________________________________________________________________________________________________________\n");
        Node *q=p;
        p = p->svt;
        free(q);
    }
}

void misAJourDim(List TS,char* nomEntite,int dim){
    Node* p = TS;
    while ((p != NULL)&&(strcmp(p->inf.nomEntite,nomEntite)!=0)){
        p=p->svt;           //  parcourir la table pour trouver l'entite en question
    }
    p->inf.dimension=dim;
}

int getDimension(List TS,char* nomEntite){
    Node* p = TS;
    while ((p != NULL)&&(strcmp(p->inf.nomEntite,nomEntite)!=0)){
        p=p->svt;           //  parcourir la table pour trouver l'entite en question
    }
    return p->inf.dimension;
}

/*
=========================== Section 2 : La table des symboles des mots résérvés ===========================
*/

typedef struct Element_{
    char* nomEntite;
    char* codeEntite;
}Element_;

typedef struct Node_{
    Element_ inf;
    struct Node_* svt;
}Node_;

typedef Node_* List_;

List_ TC = NULL;

int rechercherMotCle(List_ TC,char* motCle){
    Node_* p = TC;
    while (p!=NULL){
        if (strcmp(p->inf.nomEntite,motCle)==0){
            return 1;       
        }
        p=p->svt;
    }
    return 0;
}

int insererMotCle (List_* TC,char* motCle,char* codeEntite){
    if (rechercherMotCle(*TC,motCle)){
        return -1;          //  Si le mot clé existe déja , on l'insère pas
    }
    else {
        Node_* p = (Node_*)malloc(sizeof(Node_));       //  créer un nouveau noeud
        p->inf.nomEntite = strdup(motCle);
        p->inf.codeEntite = strdup(codeEntite);
        p->svt = NULL;
        if (*TC == NULL){           //  insertion au début
            *TC = p;
            return 0;
        }
        else{
            Node_* head = *TC;
            while (head->svt != NULL){
                head=head->svt;
            }
            head->svt = p;
            return 0;
        }
    }
}



void afficherTC (List_ TC){
    Node_* p = TC;
    printf("\t\t\t\t\t___________ LA TABLE DES MOTS CLES ___________\n\n");
    printf ("\t\t\t\t\t|    Nom Entite\t    |Code Entite\t      |");
    printf ("\n\t\t\t\t\t______________________________________________\n");
    while (p != NULL){
        printf("\t\t\t\t\t|    %-20s|%-20s|",p->inf.nomEntite,p->inf.codeEntite);
        printf("\n\t\t\t\t\t______________________________________________\n");
        Node_* q=p;
        p=p->svt;
        free(q);
    }
}


void afficher (List TS , List_ TC){     //  permet d'afficher les deux tables simultanément
    afficherTS(TS);
    printf("\n\n\n");
    afficherTC(TC);
}

/*
=======================================================================================================
*/

void decoupage(char* str, char* str1, int* dim) {      
     //  cette procédure permet de découper une chaine passée en entrée et la décomposer en partie idf et une partie entière si elle existe
    int i = 0;
    if (strchr(str,'[')==NULL){     //  il s'agit d'une variable simple
        strcpy(str1,str);
        *dim=1;
    }
    else{
    while ((str[i]!='\n')&&(str[i] != '[')) {       //  prendre la partie identificateur d'un vecteur
        str1[i] = str[i];
        i++;
    }
    str1[i] = '\0';         //  marquer la fin 
    i++;

    char intermediare[20];
    int j = i;

    while (str[i] != ']') {         //  extraire la partie entière écrite sous forme d'une suite de caractère
        intermediare[i-j] = str[i];
        i++;
    }
    intermediare[j] = '\0';

    *dim = atoi(intermediare);     //  convertir la chaine en un nombre
    }
}



