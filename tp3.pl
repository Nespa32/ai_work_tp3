
% Exercise 1.
/* static data */
timetable(edinburgh,london,
		[ 9:40/10:50/ba4733/alldays,
		 13:40/14:50/ba4773/alldays,
	 	 19:40/20:50/ba4833/[mo,tu,we,th,fr,su]]).

timetable(london,edinburgh,
		[ 9:40/10:50/ba4732/alldays,
		 11:40/12:50/ba4752/alldays,
	 	 18:40/19:50/ba4822/[mo,tu,we,th,fr]]).

timetable(london,ljubljana,
		[13:20/16:20/ju201/[fr],
	 	 13:20/16:20/ju213/[su]]).

timetable(london,zurich,
		[ 9:10/11:45/ba614/alldays,
		 14:45/17:20/sr805/alldays]).

timetable(london,milan,
		[ 8:30/11:20/ba510/alldays,
		 11:00/13:50/az459/alldays]).

timetable(ljubljana,zurich,
		[11:30/12:40/ju322/[tu,th]]).

timetable(ljubljana,london,
		[11:10/12:20/yu200/[fr],
		 11:25/12:20/yu212/[su]]).

timetable(milan,london,
		[ 9:10/10:00/az458/alldays,
		 12:20/13:10/ba511/alldays]).

timetable(milan,zurich,
		[ 9:25/10:15/sr621/alldays,
		 12:45/13:35/sr623/alldays]).

timetable(zurich,ljubljana,
		[13:30/14:40/yu323/[tu,th]]).

timetable(zurich,london,
		[ 9:00/9:40/ba613/[mo,tu,we,th,fr,sa],
	 	 16:10/16:55/sr806/[mo,tu,we,th,fr,su]]).

timetable(zurich,milan,
		[ 7:55/8:45/sr620/alldays]).

/* operator defines */
% '/' has to have a larger precedence so that we can break a phrase into slices divided by '/'
% see http://www.swi-prolog.org/pldoc/man?predicate=op/3
:- op(1000, yfx, :).
:- op(1150, yfx, /).

/* actual useful code */
/* calculate a route */
route(From, To, Day, X) :- route_aux(From, To, Day, X, []).

route_aux(From, To, Day, [From-To:FlightNum:DepTime], _) :- flight(From, To, Day, FlightNum, DepTime, _).
route_aux(From, To, Day, [From-X:FlightNum:DepTime|T], VISITED_SET) :-
    not_member_of_list(From, VISITED_SET), /* avoid loops with VISITED_SET*/
    flight(From, X, Day, FlightNum, DepTime, ArrTime),
    append([From], VISITED_SET, NEW_VISITED_SET),
    route_aux(X, To, Day, T, NEW_VISITED_SET),
    deptime(T, NextDepTime),
    transfer(ArrTime, NextDepTime).

/* helper */
not_member_of_list(_, []) :- !.
not_member_of_list(X, [H|T]) :- X \= H, not_member_of_list(X, T).

match_day(_, alldays).
match_day(X, [X]).
match_day(X, [_|T]) :- match_day(X, T).

match_times(DepTime, ArrTime, FlightNum, Day, [DepTime/ArrTime/FlightNum/Days|_]) :- match_day(Day, Days).
match_times(DepTime, ArrTime, FlightNum, Day, [_|T]) :- match_times(DepTime, ArrTime, FlightNum, Day, T).

/* example:
:-? flight(zurich, milan, Day, FlightNum, DepTime, ArrTime).

FlightNum = sr620,
DepTime = (7:55),
ArrTime = (8:45)

*/

flight(P1, P2, Day, FlightNum, DepTime, ArrTime) :- timetable(P1, P2, TL), match_times(DepTime, ArrTime, FlightNum, Day, TL).

/* deptime(Route, Time) */
deptime([_-_:_:DepTime|_], DepTime).

/* transfer(Time1, Time2) */
/* in a nutshell, Time1 + 40 <= Time2 */
/* '<=' apparently does not exist in Prolog */
transfer(H1:T1, H2:T2) :- N1 is ((H1 * 60 + T1) + 40) mod (24 * 60), N2 is (H2 * 60 + T2) + 1, N1 < N2.


% Exercise 2.
sentenca --> frase_nom, frase_verb.
sentenca --> frase_nom_p, frase_verb_p.

frase_nom --> artigo_f, subst_f.
frase_nom --> artigo_m, subst_m.
frase_nom --> subst_f.
frase_nom --> subst_m.

frase_nom_p --> artigo_p_f, subst_p_f.
frase_nom_p --> artigo_p_m, subst_p_m.
frase_nom_p --> subst_p_f.
frase_nom_p --> subst_p_m.

frase_verb --> verbo.
frase_verb --> verbo, preposicao, frase_nom.
frase_verb --> verbo, preposicao, frase_nom_p.
frase_verb_p --> verbo_p.
frase_verb_p --> verbo_p, preposicao, frase_nom.
frase_verb_p --> verbo_p, preposicao, frase_nom_p.

artigo_f --> [a].
artigo_f --> ['A'].
artigo_m --> [o].
artigo_m --> ['O'].
artigo_p_f --> [as].
artigo_p_f --> ['As'].
artigo_p_m --> [os].
artigo_p_m --> ['Os'].

subst_f --> [menina].
subst_f --> [floresta].
subst_f --> [mae].
subst_f --> [vida].
subst_f --> [noticia].
subst_f --> [cidade].
subst_f --> [porta].
subst_p_f --> [lagrimas].
subst_m --> [tempo].
subst_m --> [cacador].
subst_m --> [rio].
subst_m --> [rosto].
subst_m --> [mar].
subst_m --> [vento].
subst_m --> [martelo].
subst_m --> [cachorro].
subst_m --> [sino].
subst_p_m --> [tambor].
subst_p_m --> [lobos].
subst_p_m --> [tambores].

verbo --> [corre].
verbo --> [correu].
verbo --> [bateu].
verbo_p --> [correram].
verbo_p --> [corriam].
verbo_p --> [batiam].
verbo_p --> [bateram].

% the test cases don't seem to need f/m or s/p qualifiers
preposicao --> [para].
preposicao --> [pela]. % s f
preposicao --> [com].
preposicao --> [pelo]. % s m
preposicao --> [a]. % s f
preposicao --> [no]. % s m
preposicao --> [na]. % s f

/* frases corretas */
/*
sentenca(['A',menina,corre,para,a,floresta],[]).
sentenca(['A',menina,corre,para,a,mae],[]).
sentenca(['A',vida,corre],[]).
sentenca(['O',tempo,corre],[]).
sentenca(['O',cacador,correu,com,os,lobos],[]).
sentenca(['A',noticia,correu,pela,cidade],[]).
sentenca(['As',lagrimas,corriam,pelo,rosto],[]).
sentenca(['O',rio,corre,para,o,mar],[]).
sentenca(['A',menina,bateu,a,porta],[]).
sentenca(['A',porta,bateu],[]).
sentenca(['O',vento,bateu,a,porta],[]).
sentenca(['A',menina,bateu,na,porta],[]).
sentenca(['O',martelo,bateu,na,porta],[]).
sentenca(['A',menina,bateu,no,cachorro],[]).
sentenca(['A',menina,bateu,no,tambor],[]).
sentenca(['Os',tambores,bateram],[]).
sentenca(['O',sino,bateu],[]).
sentenca(['A',menina,corre],[]).
sentenca(['A',vida,correu],[]).
sentenca(['A',noticia,correu,para,a,floresta],[]).
sentenca(['A',vida,correu,com,os,lobos],[]).
sentenca(['A',menina,bateu,a,mae],[]).
*/

/* frases erradas */
/*
sentenca(['A',tempo,corre],[]).
sentenca(['O',tempo,correram],[]).
sentenca(['A',cacador,corriam,pela,rosto],[]).
sentenca(['A',tambores,correu,pela,floresta],[]).
sentenca(['Os',tambores,bateu,na,porta],[]).
sentenca(['O',sino,bateu,na,meninas],[]).
*/

