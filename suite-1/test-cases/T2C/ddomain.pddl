(define (domain DT2)
(:requirements :adl :fluents)
(:types
	event state comp obs fault - object
	aevent cevent eevent - event
)
(:predicates 
(current ?s - state ?c - comp)
(edge ?s1 ?s2 - state ?e - event ?c - comp)
(pending ?o - object)
(precedes ?oi ?oj - object)
(observable ?e - event) 
(future ?o - obs)
(only-effect)
(synch ?ce - cevent ?ee - eevent) 
(cause ?c - comp ?e - cevent) 
(effect ?c - comp ?e - event)
(related ?c1 ?c2 - comp)
(as ?o - obs ?e - event ?c - comp)
(occurred ?o - object)
(hyp ?e - event ?f - fault ?c - comp)
(consumed ?e - event ?c - comp)
(faulty ?e - event)
(endobs)(endflt)(stop)(stop-obs)(last-obs)(look-ahead)(allowed ?c - comp)(prefix)
)


(:action silent-asynch

:parameters (?s1 ?s2 - state ?e - aevent ?c - comp)

:precondition (and (not (only-effect)) (not (observable ?e)) (not (faulty ?e))(current ?s1 ?c) (edge ?s1 ?s2 ?e ?c))

:effect (and (not (last-obs)) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c))))
)


(:action observable-asynch

:parameters (?s1 ?s2 - state ?e - aevent ?c - comp ?o - obs)

:precondition (and (not (only-effect)) (current ?s1 ?c) (edge ?s1 ?s2 ?e ?c)(not (faulty ?e)) (observable ?e) (pending ?o) (as ?o ?e ?c))

:effect (and (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c))) (occurred ?o) (not (pending ?o)) (last-obs))
)


(:action hyp-faulty-cause

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent ?f - fault)

:precondition (and (not(only-effect)) (not (observable ?e)) (faulty ?e) (current ?s1 ?c) (edge ?s1 ?s2 ?e ?c) (not (occurred ?f)) (hyp ?e ?f ?c))

:effect (and (consumed ?e ?c) (only-effect) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c)))(cause ?c ?e)  (occurred ?f))
)


(:action redo-faulty-cause

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent)

:precondition (and (not(only-effect)) (not (observable ?e)) (faulty ?e) (current ?s1 ?c) (edge ?s1 ?s2 ?e ?c)(consumed ?e ?c))

:effect (and (consumed ?e ?c) (only-effect) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c))) (cause ?c ?e))

)


(:action la-faulty-cause-a

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent)

:precondition (and (not (prefix))(look-ahead)(allowed ?c)(not (consumed ?e ?c)) (not(only-effect)) (not (observable ?e)) (faulty ?e)(current ?s1 ?c) (edge ?s1 ?s2 ?e ?c))

:effect (and (only-effect) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c))) (cause ?c ?e))
)


(:action la-faulty-cause-p

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent)

:precondition (and (endflt)(prefix)(look-ahead)(not (consumed ?e ?c)) (not(only-effect)) (not (observable ?e)) (faulty ?e)(current ?s1 ?c) (edge ?s1 ?s2 ?e ?c))

:effect (and (only-effect) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c))) (cause ?c ?e))
)


(:action la-faulty-cause-f

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent)

:precondition (and (not (prefix))(look-ahead)(not (consumed ?e ?c)) (not(only-effect)) (not (observable ?e)) (faulty ?e)(current ?s1 ?c) (edge ?s1 ?s2 ?e ?c))

:effect (and (only-effect) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c))) (cause ?c ?e))
)






(:action synch-effect

:parameters(?s1 ?s2 - state ?ec - cevent ?ee - eevent ?ce ?cc - comp)

:precondition (and (only-effect) (cause ?cc ?ec) (related ?cc ?ce) (not(effect ?ce ?ee)) (synch ?ec ?ee) (current ?s1 ?ce)(edge ?s1 ?s2 ?ee ?ce) )

:effect (and (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?ce)) (current ?s2 ?ce))) (effect ?ce ?ee))
)

(:action synchronize

:parameters (?cc - comp ?ec - cevent ?ee - eevent)

:precondition (and (only-effect) (cause ?cc ?ec) (forall (?cp - comp) (imply (related ?cc ?cp) (effect ?cp ?ee))))

:effect(and (not (last-obs))(not(cause ?cc ?ec)) (not(only-effect)) (forall (?cp - comp) (not(effect ?cp ?ee))))
)

(:action advance-observation-to

:parameters (?o - obs)

:precondition (and (future ?o) (forall (?oi - obs) (imply (precedes ?oi ?o)(occurred ?oi))))

:effect (and (not(future ?o)) (pending ?o))
)

(:action allobs

:parameters ()

:precondition (forall (?oi - obs) (occurred ?oi))

:effect (endobs)
)

(:action allflt

:parameters ()

:precondition (and (forall (?fi - fault) (occurred ?fi)) (not (only-effect)))

:effect (endflt)
)

(:action end-obs

:parameters ()

:precondition (and (endobs) (endflt) (last-obs))

:effect (stop-obs)
)

(:action end

:parameters ()

:precondition (and (endobs) (endflt))

:effect (stop)
)
)
