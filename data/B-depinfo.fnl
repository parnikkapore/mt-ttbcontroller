; Service definitions
(local L20/0 {:flags "L Nlw:eB/1->p8r" :traintag :L})
(local L20/1 {:flags "L Woo:eB/2->p1r" :traintag [:L :Nlw:pW]})
(local R20/0 {:flags "R Ler:eB/1->t2 Cmo:eB/1->t2 Nlw:eB/1->p7r" :traintag :R})
(local R20/1 {:flags "R Cmo:eB/2->t3 Ler:eB/2->t3 Woo:eB/2->p2r" :traintag [:R :Nlw:pW]})

; Tripcode mappings
{
  :L200 L20/0
  :L202 L20/0
  :L204 L20/0
  :L206 L20/0
  :L208 L20/0

  :L201 L20/1
  :L203 L20/1
  :L205 L20/1
  :L207 L20/1
  :L209 L20/1

  :R200 R20/0
  :R202 R20/0

  :R201 R20/1
  :R203 R20/1
}
