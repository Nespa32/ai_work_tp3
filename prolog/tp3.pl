
% Exercise 1.
/* static data */
/* operator defines */
% '/' has to have a larger precedence so that we can break a phrase into slices divided by '/'
% see http://www.swi-prolog.org/pldoc/man?predicate=op/3
:- op(1000, yfx, :).
:- op(1150, yfx, /).

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
match_day(X, [X|_]).
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

% visit a list of cities with a known start/end
visit(Start, Day, CityList, Route) :- visit_aux(Start, Start, Day, CityList, Route).

remove(X, [X|T], T) :- !.
remove(X, [Y|T1], [Y|T2]) :-
    remove(X, T1, T2).

% just a static helper
next_day(mo, tu).
next_day(tu, we).
next_day(we, th).
next_day(th, fr).
next_day(fr, sa).
next_day(sa, su).
next_day(su, mo).

visit_aux(End, Start, Day, [], [Start-End:FlightNum:Day:DepTime]) :-
    flight(Start, End, Day, FlightNum, DepTime, _).
visit_aux(End, Start, Day, CityList, [Start-Next:FlightNum:Day:DepTime|RestOfRoute]) :-
    member(Next, CityList),
    flight(Start, Next, Day, FlightNum, DepTime, _),
    next_day(Day, NextDay),
    remove(Next, CityList, LeftoverCityList),
    visit_aux(End, Next, NextDay, LeftoverCityList, RestOfRoute).

% Exercise 2.
sentenca(sent(FN, FV)) --> frase_nom(FN), frase_verb(FV).
sentenca(sent(FN, FV)) --> frase_nom_p(FN), frase_verb_p(FV).

frase_nom(frase_nom(A, S)) --> artigo_f(A), subst_f(S).
frase_nom(frase_nom(A, S)) --> artigo_m(A), subst_m(S).
frase_nom(frase_nom(S)) --> subst_f(S).
frase_nom(frase_nom(S)) --> subst_m(S).

frase_nom_p(frase_nom_p(A, S)) --> artigo_p_f(A), subst_p_f(S).
frase_nom_p(frase_nom_p(A, S)) --> artigo_p_m(A), subst_p_m(S).
frase_nom_p(frase_nom_p(S)) --> subst_p_f(S).
frase_nom_p(frase_nom_p(S)) --> subst_p_m(S).

frase_verb(frase_verbal(V)) --> verbo(V).
frase_verb(frase_verbal(V, P, FN)) --> verbo(V), preposicao(P), frase_nom(FN).
frase_verb(frase_verbal(V, P, FN)) --> verbo(V), preposicao(P), frase_nom_p(FN).
frase_verb_p(frase_verbal_p(V)) --> verbo_p(V).
frase_verb_p(frase_verbal_p(V, P, FN)) --> verbo_p(V), preposicao(P), frase_nom(FN).
frase_verb_p(frase_verbal_p(V, P, FN)) --> verbo_p(V), preposicao(P), frase_nom_p(FN).

artigo_f(artigo(a)) --> [a].
artigo_f(artigo('A')) --> ['A'].
artigo_m(artigo(o)) --> [o].
artigo_m(artigo('O')) --> ['O'].
artigo_p_f(artigo(as)) --> [as].
artigo_p_f(artigo('As')) --> ['As'].
artigo_p_m(artigo(os)) --> [os].
artigo_p_m(artigo('Os')) --> ['Os'].

subst_f(substantivo(menina)) --> [menina].
subst_f(substantivo(floresta)) --> [floresta].
subst_f(substantivo(mae)) --> [mae].
subst_f(substantivo(vida)) --> [vida].
subst_f(substantivo(noticia)) --> [noticia].
subst_f(substantivo(cidade)) --> [cidade].
subst_f(substantivo(porta)) --> [porta].
subst_p_f(substantivo(lagrimas)) --> [lagrimas].
subst_m(substantivo(tempo)) --> [tempo].
subst_m(substantivo(cacador)) --> [cacador].
subst_m(substantivo(rio)) --> [rio].
subst_m(substantivo(rosto)) --> [rosto].
subst_m(substantivo(mar)) --> [mar].
subst_m(substantivo(vento)) --> [vento].
subst_m(substantivo(martelo)) --> [martelo].
subst_m(substantivo(cachorro)) --> [cachorro].
subst_m(substantivo(sino)) --> [sino].
subst_p_m(substantivo(tambor)) --> [tambor].
subst_p_m(substantivo(lobos)) --> [lobos].
subst_p_m(substantivo(tambores)) --> [tambores].

verbo(verbo(corre)) --> [corre].
verbo(verbo(correu)) --> [correu].
verbo(verbo(bateu)) --> [bateu].
verbo_p(verbo_p(correram)) --> [correram].
verbo_p(verbo_p(corriam)) --> [corriam].
verbo_p(verbo_p(batiam)) --> [batiam].
verbo_p(verbo_p(bateram)) --> [bateram].

% the test cases don't seem to need f/m or s/p qualifiers
preposicao(preposicao(para)) --> [para].
preposicao(preposicao(pela)) --> [pela]. % s f
preposicao(preposicao(com)) --> [com].
preposicao(preposicao(pelo)) --> [pelo]. % s m
preposicao(preposicao(a)) --> [a]. % s f
preposicao(preposicao(no)) --> [no]. % s m
preposicao(preposicao(na)) --> [na]. % s f

% for using 2 arguments only
sentenca --> sentenca(_).

% test cases
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

% derivation tree printing
/*
sentenca(X,['A',vida,corre],[])
X = sent(frase_nom(artigo('A'),substantivo(vida)),frase_verbal(verbo(corre))).
*/

