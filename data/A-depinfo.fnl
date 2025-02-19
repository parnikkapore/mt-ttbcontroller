; Service definitions
(local L10/1 {:flags "L Dbo:p1-skip" :traintag "L"})
(local L10/2 {:flags "L jKkL:A/2->A1/2 Ikc:p2-no-reverse Dbo:eA1/2->p1r" :traintag "L"})
(local R10/0 {:flags "R Dsm:eA/1->p2 Brl:eA/1->p2 Nlw:eA/1->p3r" :traintag "R"})
(local R10/1 {:flags "R Brl:eA/2->p3 Dsm:eA/2->p3 Prs:p4->sht1n Prs:sht1n->p1" :traintag [:R :Nlw:pN]})

; Tripcode mappings
{
 :L100 L10/1
 :L102 L10/1
 :L104 L10/1
 :L106 L10/1
 :L108 L10/1

 :L101 L10/2
 :L103 L10/2
 :L105 L10/2
 :L107 L10/2
 :L109 L10/2

 :R100 R10/0
 :R102 R10/0

 :R101 R10/1
 :R103 R10/1
}
