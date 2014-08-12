; G domain - 3 IFP def - LA
(define (domain DT1C)
(:requirements :adl :fluents)
(:types event state comp obs fault - object
aevent cevent eevent - event)
(:predicates
(current ?s - state ?c - comp)
(edge ?s1 ?s2 - state ?e - event ?c - comp)
(observable ?e - event)
(only-effect)
(synch ?ce - cevent ?ee - eevent)
(cause ?c - comp ?e - cevent)
(effect ?c - comp ?e - event)
(related ?c1 ?c2 - comp)
(occurred ?o - object)
(hyp ?e - event ?f - fault ?c - comp)
(consumed ?e - event ?c - comp)
(faulty ?e - event)

(not-all-x)
(stop)
(stop-obs)
(stop-both)
(last-obs)
(last-flt)
(endflt)
(xextra ?c - comp)
(xla ?c - comp)
(isx ?c - comp)
(extra-fault)
)


(:action silent-asynch

:parameters (?s1 ?s2 - state ?e - aevent ?c - comp)

:precondition (and (not (only-effect)) (not (observable ?e)) (not (faulty ?e))(current ?s1 ?c) (edge ?s1 ?s2 ?e ?c))

:effect (and (not (last-obs)) (not (last-flt)) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c))))
)


(:action observable-asynch

:parameters (?s1 ?s2 - state ?e - aevent ?c - comp)

:precondition (and (not (only-effect)) (current ?s1 ?c) (edge ?s1 ?s2 ?e ?c)(not (faulty ?e)) (observable ?e))

:effect (and (not (last-flt)) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c)))(last-obs))
)


(:action faulty-cause

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent ?f - fault)

:precondition (and (not(only-effect)) (not (observable ?e)) (faulty ?e) (current ?s1 ?c) (edge ?s1 ?s2 ?e ?c)(not (occurred ?f)) (hyp ?e ?f ?c))

:effect (and (consumed ?e ?c) (only-effect) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c)))(cause ?c ?e) (occurred ?f))
)


(:action redo-faulty-cause

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent)

:precondition (and (not(only-effect)) (not (observable ?e)) (faulty ?e) (current ?s1 ?c) (edge ?s1 ?s2 ?e ?c) (consumed ?e ?c))

:effect (and (only-effect) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c))) (cause ?c ?e))
)


(:action extra-fault-cause

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent)

:precondition (and (not (consumed ?e ?c)) (not(only-effect)) (not (extra-fault)) (endflt) (not (xextra ?c))(not (observable ?e)) (faulty ?e)(current ?s1 ?c) (edge ?s1 ?s2 ?e ?c))

:effect (and (only-effect)(when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c)) (current ?s2 ?c)))(cause ?c ?e) (consumed ?e ?c) (extra-fault))
)


(:action la-faulty-cause

:parameters (?c - comp ?s1 ?s2 - state ?e - cevent)

:precondition (and (not (xla ?c)) (extra-fault)(not (consumed ?e ?c))(not(only-effect))(not (observable ?e)) (faulty ?e)(current ?s1 ?c) (edge ?s1 ?s2 ?e ?c))

:effect (and (only-effect)(last-flt)(consumed ?e ?c) (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?c))(current ?s2 ?c))) (cause ?c ?e) (when (not (isx ?c)) (not-all-x)))

)


(:action synch-effect

:parameters(?s1 ?s2 - state ?ec - cevent ?ee - eevent ?ce ?cc - comp)

:precondition (and (only-effect) (cause ?cc ?ec) (related ?cc ?ce) (not(effect ?ce ?ee)) (synch ?ec ?ee) (current ?s1 ?ce)(edge ?s1 ?s2 ?ee ?ce))

:effect (and (when (not (= ?s1 ?s2)) (and (not(current ?s1 ?ce)) (current ?s2 ?ce))) (effect ?ce ?ee))
)


(:action synchronize

:parameters (?cc - comp ?ec - cevent ?ee - eevent)

:precondition (and (only-effect) (cause ?cc ?ec) (forall (?cp - comp) (imply (related ?cc ?cp) (effect ?cp ?ee))))

:effect(and (not(cause ?cc ?ec)) (not (last-obs))(not(only-effect)) (forall (?cp - comp) (not(effect ?cp ?ee))))
)


(:action allflt

:parameters ()

:precondition (and (forall (?fi - fault) (occurred ?fi)) (not (only-effect)))

:effect (endflt)
)


(:action physically-possible

:parameters ()

:precondition (and (endflt) (not (only-effect)) (extra-fault))

:effect (stop)
)

(:action physically-possible-obs

:parameters ()

:precondition (and (endflt) (not (only-effect)) (extra-fault) (last-obs))

:effect (stop-obs)
)


(:action physically-possible-both

:parameters ()

:precondition (and (endflt) (not (only-effect)) (extra-fault) (or (last-obs) (last-flt)))

:effect (stop-both)
)
)