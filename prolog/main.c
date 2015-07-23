
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include <SWI-Prolog.h>

#define MAX_LINE_SIZE 2048

void print_compound(term_t t);
void print_list(term_t inp);
void build_list(term_t l, int n, char** words);

void flight(char* source, char* dest);
void route(char* source, char* dest, char* day);
void visit(char* source, char* day, char** location_list, int n_dest);

void synt_parse_tree(char** sentence_list, int n_words);
void synt_analyze(char** sentence_list, int n_words, int print_parse);

int main(int argc, char** argv)
{
    char* av[2] = { argv[0], NULL };
    if (!PL_initialise(1, av))
        PL_halt(1);

    printf("Options:\n");
    printf("\t1: Check what days can you fly between two locations\n");
    printf("\t2: Plan a travel route between two locations\n");
    printf("\t3: Plan a larger trip starting and ending in a given location and date, passing by a list of destinations (one per day)\n");
    printf("\t4: Analyze a sentence\n");
    printf("\t5: Analyze a sentence, print parse tree\n");
    
    // read option
    int option;
    scanf("%d", &option);

    switch (option)
    {
        case 1: // flight between 2 locations
        {
            printf("Input an initial location (edinburgh/london/ljubljana/zurich/milan): ");
            char initialLocStr[MAX_LINE_SIZE];
            scanf(" %s", initialLocStr);

            printf("Input a final location: (edinburgh/london/ljubljana/zurich/milan): ");
            char finalLocStr[MAX_LINE_SIZE];
            scanf(" %s", finalLocStr);

            flight(initialLocStr, finalLocStr);
            break;
        }
        case 2: // route between 2 locations
        {
            printf("Input an initial location (edinburgh/london/ljubljana/zurich/milan): ");
            char initialLocStr[MAX_LINE_SIZE];
            scanf(" %s", initialLocStr);

            printf("Input a final location (edinburgh/london/ljubljana/zurich/milan): ");
            char finalLocStr[MAX_LINE_SIZE];
            scanf(" %s", finalLocStr);

            char setTravelDayStr[MAX_LINE_SIZE];
            printf("Which day (mo/tu/we/th/fr/sa/su/alldays)?: ");
            scanf(" %s", setTravelDayStr);

            route(initialLocStr, finalLocStr, setTravelDayStr);
            break;
        }
        case 3: // larger trip
        {
            printf("Input an initial location (edinburgh/london/ljubljana/zurich/milan): ");
            char locationStr[MAX_LINE_SIZE];
            scanf(" %s", locationStr);

            printf("Input the start day (mo/tu/we/th/fr/sa/su/alldays): ");
            char startDayStr[MAX_LINE_SIZE];
            scanf(" %s", startDayStr);

            int i, n;
            printf("Input the number of destinations: ");
            scanf("%d", &n);

            char** location_list = (char**)malloc(sizeof(char*) * n);

            for (i = 0; i < n; i++)
            {
                printf("Location #%d (edinburgh/london/ljubljana/zurich/milan): ", i + 1);
                
                char str[MAX_LINE_SIZE];
                scanf(" %s", str);

                location_list[i] = (char*)malloc(MAX_LINE_SIZE);
                strcpy(location_list[i], str);
            }

            visit(locationStr, startDayStr, location_list, n);

            for (i = 0; i < n; i++)
                free(location_list[i]);
            
            free(location_list);
            break;
        }
        case 4: // Analyze sentence
        case 5: // Analyze sentence, print parse tree
        {
            printf("Input sentence: \n");
    
            char str[MAX_LINE_SIZE];
            scanf(" %[^\n]", str);

            char** sentence_list = (char**)malloc(sizeof(char*));
            char* p = strtok(str, " ");
            int n = 0;

            while (p)
            {
                sentence_list = (char**)realloc(sentence_list, sizeof(char*)*  ++n);
                sentence_list[n - 1] = p;

                p = strtok(NULL, " ");
            }

            sentence_list = realloc(sentence_list, sizeof(char*)* (n + 1));
            sentence_list[n] = 0;

            synt_analyze(sentence_list, n, option == 5 ? 1 : 0);

            free(sentence_list);
            break;
        }
        default:
            printf("Invalid option %d, exiting", option);
            break;
    }

    PL_halt(0);
    return 0;
}

void print_compound(term_t t)
{
    term_t ll = PL_new_term_ref();
    int arity, len, n;
    char* s;
    atom_t name;

    switch (PL_term_type(t))
    {
        case PL_VARIABLE:
        case PL_ATOM:
        case PL_INTEGER:
        case PL_FLOAT:
            PL_get_chars(t, &s, CVT_ALL);
            printf("%s", s);
            break;
        case PL_TERM:
            PL_get_name_arity(t, &name, &arity);
            printf("%s(", PL_atom_chars(name));

            for (n = 1; n <= arity; n++)
            {
                PL_get_arg(n, t, ll);
                print_compound(ll);

                if (n == arity)
                    printf(")");
                else
                    printf(", ");
            }

            break;
        default:
            break;
    }
}

void print_list(term_t inp)
{
    term_t head = PL_new_term_ref();
    term_t list = PL_copy_term_ref(inp);

    while (PL_get_list(list, head, list))
    {
        print_compound(head);
        printf("\n");
    }
}

void build_list(term_t l, int n, char** words)
{
    term_t a = PL_new_term_ref();
    PL_put_nil(l);

    while (--n >= 0)
    {
        PL_put_atom_chars(a, words[n]);
        PL_cons_list(l, a, l);
    }
}

void flight(char* source, char* dest)
{
    predicate_t pred = PL_predicate("flight", 6, "main");
    term_t h0 = PL_new_term_refs(6);

    PL_put_atom_chars(h0, source);
    PL_put_atom_chars(h0 + 1, dest);

    qid_t current_query = PL_open_query(NULL, PL_Q_NORMAL, pred, h0);

    if (PL_next_solution(current_query))
    {
        do
        {
            char* s;
            if (PL_get_atom_chars(h0 + 2, &s))
                printf("%s ", s);
        }
        while (PL_next_solution(current_query));
        
        printf("\n");
    }
    else
        printf("No available days for this flight (invalid input data?)\n");

    PL_close_query(current_query);
}

void route(char* source, char* dest, char* day)
{
    predicate_t pred = PL_predicate("route", 4, "main");
    term_t h0 = PL_new_term_refs(4);

    PL_put_atom_chars(h0, source);
    PL_put_atom_chars(h0 + 1, dest);
    PL_put_atom_chars(h0 + 2, day);

    qid_t current_query = PL_open_query(NULL, PL_Q_NORMAL, pred, h0);

    if (PL_next_solution(current_query))
    {
        int first = 1;
        
        do
        {
            if (first == 0)
            {
                printf("Keep looking (y/n)? ");
                char continueStr[MAX_LINE_SIZE];
                scanf(" %s", continueStr);

                if (continueStr[0] == 'n')
                    break;
            }
            
            first = 0;
            
            print_list(h0 + 3);
        }
        while (PL_next_solution(current_query));
    }
    else
        printf("No route available\n");

    PL_close_query(current_query);
}

void visit(char* source, char* day, char** location_list, int n_dest)
{
    predicate_t pred = PL_predicate("visit", 4, "main");
    term_t h0 = PL_new_term_refs(4);

    PL_put_atom_chars(h0, source);
    PL_put_atom_chars(h0 + 1, day);

    build_list(h0 + 2, n_dest, location_list);

    qid_t current_query = PL_open_query(NULL, PL_Q_NORMAL, pred, h0);

    if (PL_next_solution(current_query))
    {
        int first = 1;
        
        do
        {
            if (first == 0)
            {
                printf("Keep looking (y/n)? ");
                char continueStr[MAX_LINE_SIZE];
                scanf(" %s", continueStr);

                if (continueStr[0] == 'n')
                    break;
            }
            
            first = 0;
            
            print_list(h0 + 3);
        }
        while (PL_next_solution(current_query));
    }
    else
        printf("No route available\n");

    PL_close_query(current_query);
}

void synt_parse_tree(char** sentence_list, int n_words)
{
    predicate_t pred = PL_predicate("sentenca", 3, "tp3");
    term_t h0 = PL_new_term_refs(3);

    build_list(h0 + 1, n_words, sentence_list);
    PL_put_nil(h0 + 2);

    qid_t current_query = PL_open_query(NULL, PL_Q_NORMAL, pred, h0);

    if (PL_next_solution(current_query))
        print_compound(h0);

    PL_close_query(current_query);
}

void synt_analyze(char** sentence_list, int n_words, int print_parse)
{
    predicate_t pred = PL_predicate("sentenca", 2, "tp3");
    term_t h0 = PL_new_term_refs(2);

    build_list(h0, n_words, sentence_list);
    PL_put_nil(h0 + 1);

    qid_t current_query = PL_open_query(NULL, PL_Q_NORMAL, pred, h0);

    if (PL_next_solution(current_query))
    {
        printf("Valid sentence\n");

        if (print_parse)
        {
            printf("\nParse tree:\n");
            synt_parse_tree(sentence_list, n_words);
        }
    }
    else
        printf("Invalid sentence\n");

    PL_close_query(current_query);
}


