%{                  //       V1.0
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>
    #include "syntaxique.tab.h"

    extern nb_ligne;
    extern yytext;
    extern col;
    extern nb_err_lex;
    int has_ISIL_io = 0;
    int has_ISIL_lang = 0;
    extern TC;
    extern TS;
   

    char sauv_type[18];
    int format_count = 0;
    int arg_count = 0;     
    int nb_err_syn = 0;

    typedef struct TabErreur{
        char* contenu;
        char* entite;
        int ligne;
        int colonne;
    }TabErreur;

    typedef struct Noeud{
        TabErreur inf;
        struct Noeud* svt;
    }Noeud;

    typedef Noeud* ListErr;

    ListErr TE = NULL;

    void addError (ListErr* TE,char* contenu,char* entite,int ligne,int colonne){
        Noeud* p = (Noeud*)malloc(sizeof(Noeud));
        p->inf.contenu=strdup(contenu);
        p->inf.entite=strdup(entite);
        p->inf.ligne=ligne;
        p->inf.colonne=colonne;
        p->svt=NULL;
        if (*TE == NULL){
            *TE = p;
        }
        else {
            Noeud* head = *TE;
            while (head->svt != NULL){
                head=head->svt;
            }
            head->svt=p;
        }
    }

    void afficherTableErreur (ListErr TE){
        printf("\n_____________________________________________________  LES ERREURS!  _______________________________________________________________\n\n");
        Noeud* p = TE;
        Noeud* q;
        while (p != NULL){
            if (strcmp(p->inf.entite,"")==0)
                printf("%s a la ligne : %d et a la colonne : %d \n",p->inf.contenu,p->inf.ligne,p->inf.colonne);
            else
                printf("%s a la ligne : %d et a la colonne : %d dans l'entite : %s \n",p->inf.contenu,p->inf.ligne,p->inf.colonne,p->inf.entite);
            printf("____________________________________________________________________________________________________________________________________\n\n");
            q=p  ;
            p=p->svt;
            free(q);
        }
    }


    typedef struct Element {
        char* valeur;               
        struct Element* suivant;
    } Element;


    typedef struct {
        Element* sommet;
    } Pile;


    void InitPile(Pile* p) {
        p->sommet = NULL; 
    }


    bool PileVide(Pile* p) {
        return p->sommet == NULL;
    }


    bool SommetPile(Pile* p, char** valeur) {
        if (PileVide(p)) {
            return false;
        }
        *valeur = p->sommet->valeur;
        return true;
    }


    bool Empiler(Pile* p, char* valeur) {
        Element* nouvelElement = (Element*)malloc(sizeof(Element)); 
        if (nouvelElement == NULL) {
            return false; // Si l'allocation échoue
        }
        nouvelElement->valeur = valeur;       
        nouvelElement->suivant = p->sommet;   
        p->sommet = nouvelElement;            
        return true;
    }


    bool Desempiler(Pile* p, char** valeur) {
        if (PileVide(p)) {
            return false;
        }
        Element* temp = p->sommet;  
        *valeur = temp->valeur;     
        p->sommet = temp->suivant;  
        free(temp);
        return true;
    }
    void EmpilerArguments(Pile* p, char* str) {
    if (!Empiler(p, str)) {
        addError(&TE,"Erreur lors de l'insertion de la chaîne dans la pile.","", nb_ligne,col);
        nb_err_syn++;
    }
}
    void EmpilerFormats(char* string, Pile* p) {
        int len = strlen(string);
        int i;
        for (i = 0; i < len; i++) {
            if (string[i] == '%' && (i + 1) < len) {
                if (string[i + 1] == 'd') {
                    Empiler(p, "%d");
                    i++;
                } else if (string[i + 1] == 'f') {
                    Empiler(p, "%f");
                    i++;
                } else if (string[i + 1] == 's') {
                    Empiler(p, "%s");
                    i++;
                }
            }
        }
    }
    int CompterElements(Pile* p) {
        int compteur = 0;
        Element* courant = p->sommet;
        while (courant != NULL) {
            compteur++; 
            courant = courant->suivant;
        }
        return compteur;
    }

    bool VerifierCompatibilite(Pile* pile1, Pile* pile2) {
        int nombreElementsPile1 = CompterElements(pile1);
        int nombreElementsPile2 = CompterElements(pile2);

        if (nombreElementsPile1 != nombreElementsPile2) {
            return false; 
        }

        char* sommet1;
        char* sommet2;

        while (!PileVide(pile1) && !PileVide(pile2)) {
            Desempiler(pile1, &sommet1);
            Desempiler(pile2, &sommet2);

            if (strcmp(sommet1, "%d") == 0 && (strcmp(sommet2, "Float") == 0 || strcmp(sommet2, "String") == 0)) {
                free(sommet1);
                free(sommet2);
                return false;
            }
            if (strcmp(sommet1, "%f") == 0 && (strcmp(sommet2, "Integer") == 0 || strcmp(sommet2, "String") == 0)) {
                free(sommet1);
                free(sommet2);
                return false;
            }
            if (strcmp(sommet1, "%s") == 0 && (strcmp(sommet2, "Integer") == 0 || strcmp(sommet2, "Float") == 0)) {
                free(sommet1);
                free(sommet2);
                return false;
            }

            free(sommet1);
            free(sommet2);
        }
        return true;
    }
    char* transfertostring(char type[18]) {
        char* newType = (char*)malloc(19 * sizeof(char));
        if (newType == NULL) {
            addError(&TE,"Allocation memoire a echoue ","", nb_ligne,col);
            nb_err_syn++;
        }
        strcpy(newType, type);
        return newType;
    }
    void IDF_DECLARE(char *param) {
        char type[18];
        char str[18];
        int dim;
    
        decoupage(param, str, &dim);
    
        getType(TS, str, type);
    
        if (strcmp(type, "") == 0) {
            addError(&TE,"Erreur semantique : Identificateur non declare",str, nb_ligne,col);
            nb_err_syn++;
        }
    }
    void check_libraries() {
        if (!has_ISIL_io) {
            addError(&TE,"Erreur : La bibliotheque ISIL.io est manquante.","", nb_ligne,col);
            nb_err_syn++;
        }
        if (!has_ISIL_lang) {
            addError(&TE,"Erreur : La bibliotheque ISIL.lang est manquante.!\n","", nb_ligne,col);
            nb_err_syn++;
        }
    }
    
    Pile P2;
    bool verifiertype(char *str1, char *str2) {
    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return (*str1 == *str2);

}

%}

%union{
    int Integer;
    float Float;
    char* str;
}

%token      MC_program MC_declaration MC_Debut MC_Fin 
            aff pvg PO PF cm add sub mul division
            or and non sup supEq inf infEq diff equal vg

%token <str>MC_import <str>BIB_io <str>BIB_lang <str>idf <str>arr <str>MC_integer <str>MC_float
        <str>MC_final <str>MC_input <str>MC_write <str>sdf <str>string1 <str>MC_if <str>MC_do <str>MC_else
        <str>MC_endIf <str>MC_for <str>MC_endFor 


%token <Float>valr <Float>signedFloat
%token <Integer>vale <Integer>signedInt 
%type <str> TYPE VAR INSTRUCTION_ECRITURE STR2 ArgumentsList Arguments INSTRUCTION_AFFECTATION EXPRESSION T F SIGNED CONDITIONIF VarCst INITIALIZATION

%left or 
%left and 
%left non
%left equal diff supEq sup inf infEq
%left add sub 
%left mul division

%start s 


%%
s                   :LIST_IMPORT MC_program idf MC_declaration LIST_DECLARATION MC_Debut LIST_INSTRUCTION MC_Fin
                    {check_libraries();
                    YYACCEPT;}
                    ;

LIST_IMPORT         :MC_import NOM_BIB LIST_IMPORT 
                    |
                    ;


NOM_BIB             :BIB_io { has_ISIL_io = 1; }
                    |BIB_lang { has_ISIL_lang = 1; }
                    ;


LIST_DECLARATION    :MC_final TYPE idf INITIALIZATION pvg LIST_DECLARATION
                    {   
                        char str[18];
                        char type[18];
                        int dim;
                        decoupage($3,str,&dim);
                        getType(TS,str,type);
                            if (strcmp(type,"")!=0){
                                addError(&TE,"Erreur Semantique : double declaration",str,nb_ligne,col);
                                nb_err_syn++;
                            }
                            else {
                                insererType(TS,str,$2);
                                misAJourDim(TS,str,dim);
                                    setFinal(TS,str);
                                    set_it(TS,str);
                                }
                        if (strcmp($2,$4)!=0){
                            addError(&TE,"Erreur semantique : non compatibilite de type dans l'initialisation",str,nb_ligne,col);
                            nb_err_syn++;
                        }
                            
                    }
                    |TYPE VAR SUB_LIST pvg LIST_DECLARATION
                    {   
                        char str[18];
                        char type[18];
                        int dim;
                        decoupage($2,str,&dim);
                        getType(TS,str,type);
                            if (strcmp(type,"")!=0){
                                addError(&TE,"Erreur Semantique : double declaration d'une entite %s","",nb_ligne,col);
                                nb_err_syn++;
                            }
                            else {
                                insererType(TS,str,$1);
                                misAJourDim(TS,str,dim);
                                                                
                              
                            }
                    }
                    |
                    ;

                    ;

TYPE                :MC_integer {strcpy(sauv_type,"Integer");}
                    |MC_float  {strcpy(sauv_type,"Float");}
                    ;

SUB_LIST            : vg VAR SUB_LIST
                    {
                        char str[18];
                        char type[18];
                        int dim;
                        decoupage($2,str,&dim);
                        getType(TS,str,type);
                            if (strcmp(type,"")!=0){
                                addError(&TE,"erreur semantique : double declaration ",str,nb_ligne,col);
                                nb_err_syn++;
                            }
                            else {
                                insererType(TS,str,sauv_type);
                                    misAJourDim(TS,str,dim);
                            
                            }
                    }
                    |
                    {
                    }
                    ;

INITIALIZATION      :aff vale
                    {
                        $$ = "Integer";
                    }
                    |aff valr
                    {
                        $$ = "Float";
                    }

                    ;


VAR                 :idf 
                    |arr {
                        int dim;
                        char str[18];
                        decoupage($1,str,&dim);
                        if (getDimension(TS,str)!=-1){
                            if (dim>getDimension(TS,str)){
                                addError(&TE,"Erreur Semantique : Depassement de la taille du vecteur ","",nb_ligne,col);
                                nb_err_syn++;
                            }
                        }
                    }
                    ;

LIST_INSTRUCTION    :INSTRUCTION LIST_INSTRUCTION
                    |
                    ;

INSTRUCTION         :INSTRUCTION_LECTURE
                    |INSTRUCTION_ECRITURE
                    |INSTRUCTION_AFFECTATION
                    |INSTRUCTION_CONDITIONNELLE
                    |INSTRUCTION_ITTERATIVE
                    ;

INSTRUCTION_LECTURE:MC_input PO sdf cm VAR PF pvg {
                        IDF_DECLARE($5);
                        Pile P3, P4;
                        char type[18];
                        char str[18];
                        int dim;
                        decoupage($5, str, &dim);
                        getType(TS, str, type);
                        char* string = transfertostring(type);
                        InitPile (&P3);
                        EmpilerFormats ($3, &P3);
                        InitPile (&P4);
                        EmpilerArguments(&P4, string);
                        if (!VerifierCompatibilite (&P3, &P4)){
                            addError(&TE,"Erreur Semantique :  Respect de formatage","", nb_ligne,col);
                            nb_err_syn++;
                        }

                    }
                    ;

INSTRUCTION_ECRITURE: MC_write PO STR2 cm ArgumentsList PF pvg {
    Pile P1;
    InitPile (&P1);
    EmpilerFormats ($3, &P1);
    if (!VerifierCompatibilite (&P1, &P2)){
        addError(&TE,"Erreur : Correspondance de signes de format dans Instruction Write","", nb_ligne,col);
        nb_err_syn++;
    }
}

STR2                :string1 {}
;

ArgumentsList
    : Arguments 
    | Arguments cm ArgumentsList
;

Arguments:VAR {
    IDF_DECLARE($1);
    char type[18];
    char str[18];
    int dim;
    decoupage($1, str, &dim);
    getType(TS, str, type);
    char* string = transfertostring(type);
    InitPile (&P2);
    EmpilerArguments(&P2, string);
}


INSTRUCTION_AFFECTATION :idf aff EXPRESSION pvg {  
                            char type[18];
                            char str[18];
                            int dim;
    
                            decoupage($1, str, &dim);
    
                            getType(TS, str, type);
    
                            IDF_DECLARE($1);
                            char* typeidf = transfertostring (type);
                                if (!verifiertype (typeidf, $3)){
                                    addError(&TE,"Erreur Semantique : L'affectation n'est pas compatible","", nb_ligne,col);
                                    nb_err_syn++;
                                }
                            if (getFinal(TS,str)==1){
                            if (set(TS,str)==true){
                                addError(&TE,"Erreur semantique : Changement de valeur d'une constante.",str,nb_ligne,col);
                                nb_err_syn++;
                            }
                            else{
                                set_it(TS,str);
                            }}
                            }
                        |arr aff EXPRESSION pvg {
                            IDF_DECLARE($1);
                            char type[18];
                            char str[18];
                            int dim;
                            decoupage($1,str,&dim);
                            if (getDimension(TS,str)>1){   
                                if ((dim>getDimension(TS,str))||(dim<1)){
                                    addError(&TE,"Erreur Semantique : Depassement de la taille du vecteur ","",nb_ligne,col);
                                    nb_err_syn++;
                                }
                            }
                            getType(TS, str, type);
                            char* typeidf = transfertostring (type);
                                if (!verifiertype (typeidf, $3)){
                                    addError(&TE,"Erreur Semantique : L'affectation n'est pas compatible","", nb_ligne,col);
                                    nb_err_syn++;
                                }
                    }
                        ;
                        

EXPRESSION          :EXPRESSION add T {
                        if (!verifiertype ($1, $3)){
                            addError(&TE,"Erreur Semantique : L'addition n'est pas compatible","", nb_ligne,col);
                            nb_err_syn++;
                        }
                    }
                    |EXPRESSION sub T {
                        if (!verifiertype ($1, $3)){
                            addError(&TE,"Erreur Semantique : La soustraction n'est pas compatible","", nb_ligne,col);
                            nb_err_syn++;
                        }
                    }
                    |T {$$ = $1;}
                    ;

T                   :T mul F {
                        if (!verifiertype ($1, $3)){
                            addError(&TE,"Erreur Semantique : La multiplication n'est pas compatible","", nb_ligne,col);
                            nb_err_syn++;
                        }
                    }
                    |T division F {
                        if (!verifiertype ($1, $3)){
                            addError(&TE,"Erreur Semantique : La division n'est pas compatible","", nb_ligne,col);
                            nb_err_syn++;
                        }
                    }
                    |F {$$ = $1;}
                    ;

F                   :idf{  
                            char type[18];
                            char str[18];
                            int dim;
    
                            decoupage($1, str, &dim);
    
                            getType(TS, str, type);
    
                            if (strcmp(type, "") == 0) {
                                IDF_DECLARE($1);
                                nb_err_syn++;
                            }
                            char* typeidf = transfertostring (type);
                            $$ = typeidf;
                            if (getFinal(TS,str)==1){
                            if (set(TS,str)==false){
                                addError(&TE,"Erreur semantique : Operation d'affectation avec constante non initialise.",str,nb_ligne,col);
                                nb_err_syn++;
                            }}
                        }
                    |arr
                    {
                        IDF_DECLARE($1);
                        char type[18];
                        char str[18];
                        int dim;
                        decoupage($1,str,&dim);
                        getType(TS , str , type);
                        if (getDimension(TS,str)>1){   
                            if ((dim>getDimension(TS,str))||(dim<1)){
                                addError(&TE,"Erreur Semantique : Depassement de la taille du vecteur ","",nb_ligne,col);
                                nb_err_syn++;
                            }
                        }
                        char* typeidf = transfertostring (type);
                        $$ = typeidf;
                    }
                    |vale {$$ = "Integer";}
                    |valr {$$ = "Float";}
                    |SIGNED {$$ = $1;}
                    |PO EXPRESSION PF {$$ = $2;}
                    ;

SIGNED              :signedInt {$$ = "Integer";}
                    |signedFloat {$$ = "Float";}
                    ;

INSTRUCTION_CONDITIONNELLE:MC_if PO LIST_CONDITION PF MC_do LIST_INSTRUCTION MC_else LIST_INSTRUCTION MC_endIf
                            ;

LIST_CONDITION      :NOT PO CONDITIONIF PF OP1 LIST_CONDITION
                    |NOT PO CONDITIONIF PF
                    ;

NOT                 :non 
                    |
                    ;

CONDITIONIF         :VarCst OP2 VarCst {
                    if (!verifiertype ($1, $3)){
                            addError(&TE,"Erreur Semantique : La Condition n'est pas compatible\n","", nb_ligne,col);
                            nb_err_syn++;
                        }
}
                    ;

VarCst              :VAR { IDF_DECLARE ($1);
                            char type[18];
                            char str[18];
                            int dim;
                            decoupage($1, str, &dim); 
                            getType(TS, str, type);
                            char* typeidf = transfertostring (type);
                            $$ = typeidf;
                        }
                    |vale {$$ = "Integer";}
                    |valr {$$ = "Float";}
                    |SIGNED {$$ = $1;}
                    ;

CONDITIONFOR        :IdfCst OP2 IdfCst
                    ;

IdfCst              :idf { IDF_DECLARE ($1);
                            char type[18];
                            char str[18];
                            int dim;
                            decoupage($1, str, &dim); 
                            getType(TS, str, type);
                            if (strcmp(type, "Integer") != 0) {
                                addError(&TE,"Erreur Semantique : Type non compatible !","", nb_ligne,col);
                                nb_err_syn++;
                            }
                        }
                    |vale
                    ;

OP1                 :and
                    |or
                    |non
                    ;

OP2                 :equal
                    |diff
                    |inf 
                    |infEq
                    |sup 
                    |supEq
                    ;

INSTRUCTION_ITTERATIVE:MC_for PO INITIALISATION pvg CONDITIONFOR pvg MISAJOUR PF MC_do LIST_INSTRUCTION MC_endFor
                        ;

INITIALISATION      :VAR aff IdfCst { IDF_DECLARE ($1);
                            char type[18];
                            char str[18];
                            int dim;
                            decoupage($1, str, &dim); 
                            getType(TS, str, type);
                            if (strcmp(type, "Integer") != 0) {
                                addError(&TE,"Erreur Semantique : Type non compatible !","", nb_ligne,col);
                                nb_err_syn++;
                            }
                        }
                    ;

MISAJOUR            :VAR add add { IDF_DECLARE ($1);
                            char type[18];
                            char str[18];
                            int dim;
                            decoupage($1, str, &dim); 
                            getType(TS, str, type);
                            if (strcmp(type, "Integer") != 0) {
                                addError(&TE,"Erreur Semantique : Type non compatible !","", nb_ligne,col);
                                nb_err_syn++;
                            }
                        }
                    |VAR sub sub { IDF_DECLARE ($1);
                            char type[18];
                            char str[18];
                            int dim;
                            decoupage($1, str, &dim); 
                            getType(TS, str, type);
                            if (strcmp(type, "Integer") != 0) {
                                addError(&TE,"Erreur Semantique : Type non compatible !","", nb_ligne,col);
                                nb_err_syn++;
                            }
                        }
                    ;

%%

yyerror()
{
nb_err_syn++;
addError(&TE,"Erreur Syntaxique","",nb_ligne,col);
nb_err_syn++;
return 1;
}

int main()
{
yyparse();
if (nb_err_syn==0 && nb_err_lex==0){
printf("\n");
printf("SYNTAXE CORRECTE !\n");
}
else{
printf("\n");
printf("SYNTAXE INCORRECTE !\n");
afficherTableErreur(TE);
}
afficher(TS,TC);
return 0;
}