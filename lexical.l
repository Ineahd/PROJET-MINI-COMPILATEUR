%{                 //       V1.0
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "syntaxique.tab.h"
    #include "TableSymbole.h"

    extern YYSTYPE yylval;
    extern nb_err_syn;
    extern TE;

    int nb_ligne = 1;
    int nb_err_lex = 0;
    int col = 1;

    int compter (char* string,char subString){
    int cpt=0,i=0;
    while (i<strlen(string)){
        if (string[i]==subString)
            cpt++;
        i++;
        }
    return cpt;
    }



%}

IDF             [A-Z]([a-zA-Z0-9]*(_[a-zA-Z0-9]+)?)*
ARR             {IDF}\[[1-9][0-9]*\]
VALE            [1-9][0-9]*|0
VALR            {VALE}((\.)[0-9]*)?
SIGNED_INT      [+-]{VALE}
SIGNED_FLOAT    [+-]{VALR}
SDF             \"%(d|f)\"
STR             \"(.|(%(d|f|s)))*\"
COMM1           \/\/.*
COMM2           #.*
COMM3           \/\*(.|\n)*\*\/
%%

"Import"        {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_import;}
"Program"       {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");return MC_program;}
"PDec"          {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");return MC_declaration;}
"InDebut"       {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");return MC_Debut;}
"InFin."        {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");return MC_Fin;}

"ISIL.io"       {col=col+yyleng;if(insererMotCle(&TC,yytext,"Nom bibliotheque")==-1){addError(&TE,"erreur semantique : double declaration d'une bibliotheque","ISIL.io",nb_ligne,col);};yylval.str=strdup(yytext);return BIB_io;}
"ISIL.lang"     {col=col+yyleng;if(insererMotCle(&TC,yytext,"Nom bibliotheque")==-1){addError(&TE,"erreur semantique : double declaration d'une bibliotheque","ISIL.lang",nb_ligne,col);};return BIB_lang;}

"Integer"       {col=col+yyleng;insererMotCle(&TC,yytext,"Type semantique");yylval.str=strdup(yytext);return MC_integer;}
"Float"         {col=col+yyleng;insererMotCle(&TC,yytext,"Type semantique");yylval.str=strdup(yytext);return MC_float;}
"final"         {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_final;}

"Input"            {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_input;}
"Write"           {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_write;}

"IF"            {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_if;}
"DO"            {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_do;}
"ELSE"          {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_else;}
"ENDIF"         {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_endIf;}

"For"           {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_for;}
"ENDFOR"        {col=col+yyleng;insererMotCle(&TC,yytext,"Mot cle");yylval.str=strdup(yytext);return MC_endFor;}

"<--"            {col=col+yyleng;return aff;}
";"             {col=col+yyleng;return pvg;}
"("             {col=col+yyleng;return PO;}
")"             {col=col+yyleng;return PF;}
","             {col=col+yyleng;return cm;}
"+"             {col=col+yyleng;return add;}
"-"             {col=col+yyleng;return sub;}
"*"             {col=col+yyleng;return mul;}
"/"             {col=col+yyleng;return division;}

"||"            {col=col+yyleng;return or;}
"&&"            {col=col+yyleng;return and;}
"!"             {col=col+yyleng;return non;}
">"             {col=col+yyleng;return sup;}
">="            {col=col+yyleng;return supEq;}
"<"             {col=col+yyleng;return inf;}
"<="            {col=col+yyleng;return infEq;}
"!="            {col=col+yyleng;return diff;}
"=="            {col=col+yyleng;return equal;}
"|"             {col=col+yyleng;return vg;}

{VALE}          {col=col+yyleng;
                int val = atoi(yytext);
                if (val >32767){
                    addError(&TE,"valeur entiere hors limite ","",nb_ligne,col);
                    nb_err_lex++;
                }
                else{
                    yylval.Integer=val;
                    return vale;
                }
                }
{VALR}          {col=col+yyleng;yylval.Float=atof(yytext);return valr;}

"("{SIGNED_INT}")"    {col=col+yyleng;yylval.str=strdup(yytext);return signedInt;}
"("{SIGNED_FLOAT}")"  {col=col+yyleng;yylval.str=strdup(yytext);return signedFloat;}

{IDF}           {col=col+yyleng;
                if (yyleng >18){
                    addError(&TE,"Erreur lexicale : L'identificateur est excessivement long.",yytext,nb_ligne,col);
                    nb_err_lex++;
                }
                else{
                    insererEntite(&TS,yytext,"Identificateur");
                        yylval.str=strdup(yytext);return idf;
                }}

{ARR}           {int dim;char id[18];
                decoupage(yytext,id,&dim);
                if (strlen(id) > 18){
                    addError(&TE,"Erreur lexicale : L'identificateur est excessivement long.",yytext,nb_ligne,col);
                    nb_err_lex++;
                }
                else{
                    if (dim >32767){
                        addError(&TE,"valeur entiere hors limite ","",nb_ligne,col);
                    }
                    else{
                    insererEntite(&TS,id,"Identificateur");
                    col=col+yyleng;yylval.str=strdup(yytext);return arr;}
                    }
                }
                
{SDF}           {col=col+yyleng;yylval.str=strdup(yytext);return sdf;}
{STR}           {col=col+yyleng;yylval.str=strdup(yytext);return string1;}

{COMM1}         {nb_ligne++;}
{COMM2}         {nb_ligne++;}
{COMM3}         {nb_ligne+=compter(yytext,'\n');}

[ \t]           {col++;}
\n              {col=1;nb_ligne++;}

.               {nb_err_lex++;
                addError(&TE,"Erreur lexicale : ",yytext,nb_ligne,col);
                }

%%
