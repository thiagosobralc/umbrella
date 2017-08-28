¿1A¿150600¿2B¿7¿3C¿19¿4D¿Posição de Entrada e Saída de Estoque¿5E¿Criado pelo usuário: 2 no dia: 05/02/2015¿6F¿release 10.5;
datawindow ( units=3 timer_interval=60000 color=1073741824 processing=0 print.printername=""  print.documentname=""  print.orientation=1 print.margin.left=635 print.margin.right=635 print.margin.top=635 print.margin.bottom=635 print.paper.size=0 print.paper.source=0 print.canusedefaultprinter=yes selected.mouse=no)
header(height=4762 color="536870912" )
summary(height=2883 color="536870912" )
footer(height=1031 color="536870912" )
detail(height=370 color="536870912" )
table(column=(type=long updatewhereclause=yes name=idproduto dbname="IDPRODUTO"  )
column=(type=long updatewhereclause=yes name=produto_grade_idsubproduto dbname="IDSUBPRODUTO"  )
column=(type=char(40) updatewhereclause=yes name=descrresproduto dbname="DESCRRESPRODUTO"  )
column=(type=decimal(3) updatewhereclause=yes name=qtdcompra dbname="QTDCOMPRA"  )
column=(type=decimal(3) updatewhereclause=yes name=qtdoutrasentradas dbname="QTDOUTRASENTRADAS"  )
column=(type=decimal(3) updatewhereclause=yes name=qtddevcompra dbname="QTDDEVCOMPRA"  )
column=(type=decimal(3) updatewhereclause=yes name=qtdvenda dbname="QTDVENDA"  )
column=(type=decimal(3) updatewhereclause=yes name=qtddevvenda dbname="QTDDEVVENDA"  )
column=(type=decimal(3) updatewhereclause=yes name=qtddisponivel dbname="QTDDISPONIVEL"  )
column=(type=decimal(3) updatewhereclause=yes name=qtdsaldoinicial dbname="QTDSALDOINICIAL"  )
column=(type=decimal(3) updatewhereclause=yes name=qtdatualestoque dbname="QTDATUALESTOQUE"  )
column=(type=decimal(3) updatewhereclause=yes name=qtdsaldoreserva dbname="QTDSALDORESERVA"  )
column=(type=long updatewhereclause=yes name=produto_idsecao dbname="IDSECAO"  )
column=(type=char(40) updatewhereclause=yes name=secao_descrsecao dbname="DESCRSECAO"  )
column=(type=long updatewhereclause=yes name=produto_idgrupo dbname="IDGRUPO"  )
column=(type=char(40) updatewhereclause=yes name=grupo_descrgrupo dbname="DESCRGRUPO"  )
column=(type=long updatewhereclause=yes name=produto_idsubgrupo dbname="IDSUBGRUPO"  )
column=(type=char(40) updatewhereclause=yes name=subgrupo_descrsubgrupo dbname="DESCRSUBGRUPO"  )
 retrieve="SELECT
    ES.IDPRODUTO
    , ES.IDSUBPRODUTO
    , PG.DESCRRESPRODUTO
    , SUM (QTDCOMPRA) AS QTDCOMPRA
    , (
        (SUM (ES.QTDENTRAESTOQUE) - SUM (QTDCOMPRA)) - SUM (QTDDEVVENDA) 
    ) AS QTDOUTRASENTRADAS
    , SUM (QTDDEVCOMPRA) AS QTDDEVCOMPRA
    , SUM (QTDVENDA) AS QTDVENDA
    , SUM (QTDDEVVENDA) AS QTDDEVVENDA
    , RESERVA.QTDDISPONIVEL
    , SALDOINICIAL.QTDSALDOINICIAL
    , SALDOFINAL.QTDSALDOFINAL AS QTDATUALESTOQUE
    , RESERVA.QTDSALDORESERVA
    , SECAO.IDSECAO
    , SECAO.DESCRSECAO
    , GRUPO.IDGRUPO
    , GRUPO.DESCRGRUPO
    , SUBGRUPO.IDSUBGRUPO
    , SUBGRUPO.DESCRSUBGRUPO 
FROM
    (
        SELECT
            ESTOQUE_SINTETICO.IDPRODUTO
            , ESTOQUE_SINTETICO.IDSUBPRODUTO
            , SUM (ESTOQUE_SINTETICO.QTDSALDOINICIAL) AS QTDSALDOINICIAL 
        FROM
            ESTOQUE_SINTETICO 
        WHERE
            DTMOVIMENTO = 
                (
                    SELECT
                        MIN(DTMOVIMENTO) 
                    FROM
                        ESTOQUE_SINTETICO AS ESTOQUE 
                    WHERE
                        ESTOQUE_SINTETICO.IDPRODUTO = ESTOQUE.IDPRODUTO 
                        AND ESTOQUE_SINTETICO.IDSUBPRODUTO = ESTOQUE.IDSUBPRODUTO 
                        AND ESTOQUE_SINTETICO.IDEMPRESA IN (:RA_IDEMPRESA)
                        AND ESTOQUE_SINTETICO.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM 
                )
        GROUP BY
            ESTOQUE_SINTETICO.IDPRODUTO
            , ESTOQUE_SINTETICO.IDSUBPRODUTO 
    ) AS SALDOINICIAL 
    JOIN
        (
            SELECT
                ESTOQUE_SINTETICO.IDPRODUTO
                , ESTOQUE_SINTETICO.IDSUBPRODUTO
                , SUM (ESTOQUE_SINTETICO.QTDATUALESTOQUE) AS QTDSALDOFINAL 
            FROM
                ESTOQUE_SINTETICO 
            WHERE
                DTMOVIMENTO = 
                    (
                        SELECT
                            MAX(DTMOVIMENTO) 
                        FROM
                            ESTOQUE_SINTETICO AS ESTOQUE 
                        WHERE
                            ESTOQUE_SINTETICO.IDPRODUTO = ESTOQUE.IDPRODUTO 
                            AND ESTOQUE_SINTETICO.IDSUBPRODUTO = ESTOQUE.IDSUBPRODUTO 
                            AND ESTOQUE_SINTETICO.IDEMPRESA IN (:RA_IDEMPRESA)
                            AND ESTOQUE_SINTETICO.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM 
                    )
            GROUP BY
                ESTOQUE_SINTETICO.IDPRODUTO
                , ESTOQUE_SINTETICO.IDSUBPRODUTO 
        ) AS SALDOFINAL 
        ON (SALDOINICIAL.IDPRODUTO = SALDOFINAL.IDPRODUTO 
        AND SALDOINICIAL.IDSUBPRODUTO = SALDOFINAL.IDSUBPRODUTO) 
    JOIN
        (
            SELECT
                IDPRODUTO
                , IDSUBPRODUTO
                , SUM (QTDSALDORESERVA) AS QTDSALDORESERVA
                , SUM (QTDDISPONIVEL) AS QTDDISPONIVEL 
            FROM
                PRODUTOS_SALDOS_VIEW PV 
            WHERE
                1 = 1 
                AND PV.IDEMPRESA IN (:RA_IDEMPRESA)
                AND PV.IDPRODUTO IN (:RA_IDSUBPRODUTO)
                AND 1 = 1 
            GROUP BY
                PV.IDPRODUTO
                , PV.IDSUBPRODUTO 
        ) AS RESERVA 
        ON (SALDOFINAL.IDPRODUTO = RESERVA.IDPRODUTO 
        AND SALDOFINAL.IDSUBPRODUTO = RESERVA.IDSUBPRODUTO) 
    JOIN
        ESTOQUE_SINTETICO AS ES 
        ON (RESERVA.IDPRODUTO = ES.IDPRODUTO 
        AND RESERVA.IDSUBPRODUTO = ES.IDSUBPRODUTO) 
    JOIN
        PRODUTO_GRADE AS PG 
        ON (ES.IDPRODUTO = PG.IDPRODUTO 
        AND ES.IDSUBPRODUTO = PG.IDSUBPRODUTO) 
    JOIN
        PRODUTO 
        ON (PG.IDPRODUTO = PRODUTO.IDPRODUTO) 
    JOIN
        SECAO 
        ON (PRODUTO.IDSECAO = SECAO.IDSECAO) 
    JOIN
        GRUPO 
        ON (PRODUTO.IDGRUPO = GRUPO.IDGRUPO) 
    JOIN
        SUBGRUPO 
        ON (PRODUTO.IDSUBGRUPO = SUBGRUPO.IDSUBGRUPO) 
WHERE
    1 = 1 
    AND ES.IDEMPRESA IN (:RA_IDEMPRESA)
    AND ES.IDLOCALESTOQUE IN (:RA_IDLOCALESTOQUE)
    AND GRUPO.IDGRUPO IN (:RA_IDGRUPO)
    AND SUBGRUPO.IDSUBGRUPO IN (:RA_IDSUBGRUPO)
    AND SECAO.IDSECAO IN (:RA_IDSECAO)
    AND ES.IDSUBPRODUTO IN (:RA_IDSUBPRODUTO)
    AND ES.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM 
    AND 1 = 1 
GROUP BY
    ES.IDPRODUTO
    , ES.IDSUBPRODUTO
    , PG.DESCRRESPRODUTO
    , SECAO.IDSECAO
    , SECAO.DESCRSECAO
    , GRUPO.IDGRUPO
    , GRUPO.DESCRGRUPO
    , SUBGRUPO.IDSUBGRUPO
    , SUBGRUPO.DESCRSUBGRUPO
    , SALDOINICIAL.QTDSALDOINICIAL
    , SALDOFINAL.QTDSALDOFINAL
    , RESERVA.QTDSALDORESERVA
    , RESERVA.QTDDISPONIVEL"
  arguments=(("RA_IDEMPRESA", numberlist), ("RA_IDLOCALESTOQUE", numberlist), ("RA_IDSECAO", numberlist), ("RA_IDGRUPO", numberlist), ("RA_IDSUBGRUPO", numberlist), ("RA_IDSUBPRODUTO", number), ("RA_DTINI", date), ("RA_DTFIM", date))
 sort="secao_descrsecao A, grupo_descrgrupo A, subgrupo_descrsubgrupo A, produto_grade_idsubproduto A"
)
group(level=1 header.height=476 trailer.height=476 by=("produto_idsecao" "secao_descrsecao"  ) header.color="536870912" trailer.color="536870912" )
group(level=2 header.height=370 trailer.height=370 by=("produto_idgrupo" "grupo_descrgrupo"  ) header.color="536870912" trailer.color="536870912" )
group(level=3 header.height=370 trailer.height=396 by=("produto_idsubgrupo" "subgrupo_descrsubgrupo"  ) header.color="536870912" trailer.color="536870912" )
group(level=4 header.height=0 trailer.height=79 by=("produto_grade_idsubproduto"  ) header.color="536870912" trailer.color="536870912" )
rectangle(name=r_2 visible="1" band=header pen.style="0" pen.width="26" pen.color="134217750" brush.hatch="6" brush.color="134217750" background.mode="2" background.color="0" x="0" y="3836" height="793" width="19843" )
compute(name=compute_23 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="211" y="238" height="370" width="14393" format="[GENERAL]" expression="uf_nomeempresa()" alignment="0" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_31 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="185" y="3333" height="370" width="3651" format="[GENERAL]" expression="uf_pasta()" alignment="0" border="0" html.valueishtml="0" crosstab.repeat=no )
line(name=l_5 visible="1" band=header background.mode="1" background.color="553648127" pen.style="0" pen.width="26" pen.color="0" x1="132" y1="238" x2="19685" y2="238" )
compute(name=compute_1 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="16906" y="291" height="423" width="2645" format="dd/mm/yyyy hh:mm:ss" expression="today()" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=computefiltros visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-7" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="1719" y="1349" height="2354" width="16324" format="[GENERAL]" expression="uf_filtros()" alignment="2" border="0" html.valueishtml="0" crosstab.repeat=no )
text(name=t_8 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="1" border="0" x="0" y="0" height="52" width="52" text="Qtde. 
Compras" html.valueishtml="0" )
line(name=l_4 visible="1" band=header background.mode="1" background.color="553648127" pen.style="0" pen.width="26" pen.color="0" x1="132" y1="3836" x2="19685" y2="3836" )
compute(name=compute_25 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-12" font.pitch="2" font.weight="700" background.mode="1" background.color="553648127" color="0" x="185" y="714" height="529" width="19367" format="[GENERAL]" expression="uf_titulo()" alignment="2" border="0" html.valueishtml="0" crosstab.repeat=no )
line(name=l_3 visible="1" band=header background.mode="1" background.color="553648127" pen.style="0" pen.width="26" pen.color="0" x1="132" y1="4630" x2="19685" y2="4630" )
line(name=l_12 visible="1" band=header background.mode="2" background.color="1073741824" pen.style="0" pen.width="26" pen.color="33554432" x1="18123" y1="3836" x2="18123" y2="4630" )
compute(name=compute_32 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="15266" y="3333" height="370" width="4286" format="[GENERAL]" expression="uf_versao()" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
text(name=produtos_view_descricaoproduto_t visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="1852" y="4233" height="370" width="5159" text="Descrição do Produto" html.valueishtml="0" )
text(name=produtos_view_idsubproduto_t visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="529" y="3836" height="740" width="1322" text="Código
Produto" html.valueishtml="0" )
text(name=t_19 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="16536" y="3836" height="740" width="1561" text="Outros
Valores" html.valueishtml="0" )
text(name=t_11 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="11773" y="3836" height="370" width="3175" text="Quant. de vendas" html.valueishtml="0" )
text(name=t_10 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="8598" y="3836" height="370" width="3175" text="Quant. de compras" html.valueishtml="0" )
line(name=l_7 visible="1" band=header background.mode="2" background.color="1073741824" pen.style="0" pen.width="26" pen.color="33554432" x1="8598" y1="3836" x2="8598" y2="4630" )
line(name=l_8 visible="1" band=header background.mode="2" background.color="1073741824" pen.style="0" pen.width="26" pen.color="33554432" x1="11773" y1="3836" x2="11773" y2="4630" )
line(name=l_9 visible="1" band=header background.mode="2" background.color="1073741824" pen.style="0" pen.width="26" pen.color="33554432" x1="14948" y1="3836" x2="14948" y2="4630" )
line(name=l_10 visible="1" band=header background.mode="2" background.color="1073741824" pen.style="0" pen.width="26" pen.color="33554432" x1="16536" y1="3836" x2="16536" y2="4630" )
line(name=l_11 visible="1" band=header background.mode="2" background.color="1073741824" pen.style="0" pen.width="26" pen.color="33554432" x1="7011" y1="3836" x2="7011" y2="4630" )
line(name=l_13 visible="1" band=header background.mode="1" background.color="553648127" pen.style="0" pen.width="26" pen.color="0" x1="8598" y1="4233" x2="14948" y2="4233" )
text(name=t_7 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="18123" y="3836" height="740" width="1561" text="Saldo
venda" html.valueishtml="0" )
text(name=t_9 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="14948" y="3836" height="740" width="1561" text="Quant. 
Reserva" html.valueishtml="0" )
text(name=t_14 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="13493" y="4233" height="370" width="1428" text="Dev." html.valueishtml="0" )
text(name=t_12 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="11773" y="4233" height="370" width="1693" text="Efetuada" html.valueishtml="0" )
text(name=t_18 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="10318" y="4233" height="370" width="1428" text="Dev." html.valueishtml="0" )
text(name=t_17 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="8598" y="4233" height="370" width="1693" text="Efetuada" html.valueishtml="0" )
text(name=t_6 visible="1" band=header font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="7011" y="3836" height="740" width="1561" text="Saldo Inicial" html.valueishtml="0" )
text(name=t_4 visible="0" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="553648127" color="0" alignment="0" border="0" x="132" y="529" height="370" width="4233" text="* Produto vendido em um kit." html.valueishtml="0" )
text(name=t_5 visible="1" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="553648127" color="0" alignment="0" border="0" x="7540" y="0" height="370" width="1719" text="Total Geral :" html.valueishtml="0" )
compute(name=compute_27 visible="1" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="132" y="1059" height="1719" width="19446" format="[GENERAL]" expression="uf_obs()" alignment="0" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_46 visible="1" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="9392" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtdcompra for all)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_48 visible="1" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="11112" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtddevcompra for all)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_15 visible="1" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="12832" y="27" height="370" width="1587" format="###,###,##0.000" expression="sum(qtdvenda for ALL) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_13 visible="1" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="14552" y="27" height="370" width="1587" format="###,###,##0.000" expression="sum(qtddevvenda for ALL)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_17 visible="1" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="16271" y="27" height="370" width="1587" format="###,###,##0.000" expression=" sum(  qtdsaldoreserva for all) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_10 visible="1" band=summary font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="17991" y="27" height="370" width="1587" format="###,###,##0.000" expression=" sum(  qtddisponivel for all) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
line(name=l_14 visible="1" band=summary background.mode="2" background.color="1073741824" pen.style="1" pen.width="26" pen.color="0" x1="2513" y1="0" x2="19711" y2="0" )
line(name=l_1 visible="1	if(page() = pagecount(),1,0)" band=footer background.mode="2" background.color="16777215" pen.style="0" pen.width="26" pen.color="0" x1="132" y1="26" x2="19685" y2="26" )
line(name=l_2 visible="1" band=footer background.mode="2" background.color="16777215" pen.style="0" pen.width="26" pen.color="0" x1="132" y1="503" x2="19685" y2="503" )
compute(name=compute_22 visible="1	if(page() = pagecount(),1,0)" band=footer font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="132" y="79" height="370" width="19446" format="[GENERAL]" expression="uf_rodape()" alignment="0" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_16 visible="1" band=footer font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="16324" y="661" height="423" width="3227" format="[general]" expression="'Página ' + page() + ' de ' + pagecount()" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
rectangle(name=r_1 visible="1	if (mod((getrow() - first(getrow() for group 2) + 1),2)=0 ,0,1)" band=detail pen.style="0" pen.width="26" pen.color="1073741824" brush.hatch="6" brush.color="134217750" background.mode="2" background.color="33554432" x="0" y="0" height="449" width="19843" )
column(name=qtdoutrasentradas visible="1" band=detail id=5 x="16536" y="0" height="370" width="1428" color="33554432" border="0" alignment="1" format="[general]" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=descrresproduto visible="1" band=detail id=3 x="1984" y="0" height="370" width="4894" color="33554432" border="0" alignment="0" format="[general]" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=produto_grade_idsubproduto visible="1" band=detail id=2 x="529" y="0" height="370" width="1322" color="33554432" border="0" alignment="0" format="[general]" html.valueishtml="0" edit.autohscroll=no edit.autoselect=yes edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=qtdcompra visible="1" band=detail id=4 x="8598" y="0" height="370" width="1428" color="33554432" border="0" alignment="1" format="###,###,##0.000" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=qtddevcompra visible="1" band=detail id=6 x="10186" y="0" height="370" width="1428" color="33554432" border="0" alignment="1" format="###,###,##0.000" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=qtdvenda visible="1" band=detail id=7 x="11773" y="0" height="370" width="1428" color="33554432" border="0" alignment="1" format="###,###,##0.000" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=qtddevvenda visible="1" band=detail id=8 x="13361" y="0" height="370" width="1428" color="33554432" border="0" alignment="1" format="###,###,##0.000" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=qtdsaldoinicial visible="1" band=detail id=10 x="7011" y="0" height="370" width="1428" color="33554432" border="0" alignment="1" format="###,###,##0.000" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=qtdsaldoreserva visible="1" band=detail id=12 x="14948" y="0" height="370" width="1428" color="33554432" border="0" alignment="1" format="###,###,##0.000" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=qtddisponivel visible="1" band=detail id=9 x="18123" y="0" height="370" width="1428" color="33554432" border="0" alignment="1" format="###,###,##0.000" html.valueishtml="0" edit.focusrectangle=no edit.autohscroll=no edit.autoselect=no edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
text(name=t_1 visible="1" band=header.1 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="0" border="0" x="132" y="0" height="370" width="1031" text="Seção :" html.valueishtml="0" )
column(name=secao_descrsecao visible="1" tag="Descricao da Secao" band=header.1 id=14 x="2381" y="0" height="370" width="6508" color="33554432" border="0" alignment="0" format="[general]" html.valueishtml="0" edit.autohscroll=no edit.autoselect=yes edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=40 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=produto_idsecao visible="1" band=header.1 id=13 x="1322" y="0" height="370" width="952" color="33554432" border="0" alignment="1" format="######" html.valueishtml="0" edit.name="Inteiro 6 posicoes" editmask.focusrectangle=no editmask.autoskip=no editmask.required=no editmask.readonly=no editmask.codetable=no editmask.ddcalendar=no editmask.spin=no editmask.useformat=no editmask.mask="######" editmask.imemode=0 criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
line(name=l_15 visible="1" band=header.1 background.mode="1" background.color="553648127" pen.style="2" pen.width="26" pen.color="0" x1="0" y1="0" x2="19552" y2="0" )
line(name=l_16 visible="1" band=header.1 background.mode="1" background.color="553648127" pen.style="2" pen.width="26" pen.color="0" x1="0" y1="397" x2="19552" y2="397" )
compute(name=compute_21 visible="1" band=trailer.1 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="132" y="0" height="370" width="9128" format="[GENERAL]" expression="'Total da Seção : ' +  secao_descrsecao " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_44 visible="1" band=trailer.1 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="11112" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtddevcompra for group 1)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_8 visible="1" band=trailer.1 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="12832" y="27" height="370" width="1587" format="###,###,##0.000" expression="sum(qtdvenda for group 1) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_6 visible="1" band=trailer.1 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="14552" y="27" height="370" width="1587" format="###,###,##0.000" expression=" sum(qtddevvenda for group 1)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_14 visible="1" band=trailer.1 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="16271" y="27" height="370" width="1587" format="###,###,##0.000" expression=" sum(  qtdsaldoreserva for group 1) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_7 visible="1" band=trailer.1 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="17991" y="27" height="370" width="1587" format="###,###,##0.000" expression=" sum(  qtddisponivel for group 1) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_40 visible="1" band=trailer.1 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="9392" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtdcompra for group 1)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
text(name=t_2 visible="1" band=header.2 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="2" border="0" x="396" y="0" height="370" width="1058" text="Grupo :" html.valueishtml="0" )
column(name=grupo_descrgrupo visible="1" band=header.2 id=16 x="2513" y="0" height="370" width="6376" color="33554432" border="0" alignment="0" format="[general]" html.valueishtml="0" edit.autohscroll=no edit.autoselect=yes edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=produto_idgrupo visible="1" band=header.2 id=15 x="1561" y="0" height="370" width="820" color="33554432" border="0" alignment="1" format="######" html.valueishtml="0" edit.name="Inteiro 6 posicoes" editmask.focusrectangle=no editmask.autoskip=no editmask.required=no editmask.readonly=no editmask.codetable=no editmask.ddcalendar=no editmask.spin=no editmask.useformat=no editmask.mask="######" editmask.imemode=0 criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
compute(name=compute_20 visible="1" band=trailer.2 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="132" y="0" height="370" width="9128" format="[GENERAL]" expression="'Total do Grupo : ' +  grupo_descrgrupo " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_43 visible="1" band=trailer.2 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="11138" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtddevcompra for group 2)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_3 visible="1" band=trailer.2 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="12832" y="0" height="370" width="1587" format="###,###,##0.000" expression=" sum(qtdvenda for group 2)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_9 visible="1" band=trailer.2 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="14552" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtddevvenda for group 2)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_12 visible="1" band=trailer.2 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="16271" y="26" height="370" width="1587" format="###,###,##0.000" expression=" sum(  qtdsaldoreserva for group 2) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_5 visible="1" band=trailer.2 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="17991" y="26" height="370" width="1587" format="###,###,##0.000" expression=" sum(  qtddisponivel  for group 2) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_39 visible="1" band=trailer.2 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="9392" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtdcompra for group 2)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
text(name=t_3 visible="1" band=header.3 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" alignment="1" border="0" x="661" y="0" height="370" width="1587" text="Subgrupo :" html.valueishtml="0" )
column(name=produto_idsubgrupo visible="1" band=header.3 id=17 x="2381" y="0" height="370" width="926" color="33554432" border="0" alignment="1" format="######" html.valueishtml="0" edit.name="Inteiro 6 posicoes" editmask.focusrectangle=no editmask.autoskip=no editmask.required=no editmask.readonly=no editmask.codetable=no editmask.ddcalendar=no editmask.spin=no editmask.useformat=no editmask.mask="######" editmask.imemode=0 criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
column(name=subgrupo_descrsubgrupo visible="1" band=header.3 id=18 x="3439" y="0" height="370" width="5423" color="33554432" border="0" alignment="0" format="[general]" html.valueishtml="0" edit.autohscroll=no edit.autoselect=yes edit.autovscroll=no edit.case=any edit.codetable=no edit.displayonly=no edit.hscrollbar=no edit.imemode=0 edit.limit=0 edit.password=no edit.vscrollbar=no edit.validatecode=no edit.nilisnull=no edit.required=no criteria.required=no criteria.override_edit=no crosstab.repeat=no background.mode="1" background.color="536870912" font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" tabsequence=0 )
line(name=l_6 visible="1" band=trailer.3 background.mode="2" background.color="1073741824" pen.style="1" pen.width="26" pen.color="0" x1="9657" y1="0" x2="19711" y2="0" )
compute(name=compute_19 visible="1" band=trailer.3 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="132" y="26" height="370" width="9128" format="[GENERAL]" expression="'Total do SubGrupo : '+ subgrupo_descrsubgrupo " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_34 visible="1" band=trailer.3 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="9392" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtdcompra for group 3)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_36 visible="1" band=trailer.3 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="11138" y="26" height="370" width="1587" format="###,###,##0.000" expression="sum(qtddevcompra for group 3)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_11 visible="1" band=trailer.3 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="12832" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtdvenda for group 3)" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_18 visible="1" band=trailer.3 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="14552" y="0" height="370" width="1587" format="###,###,##0.000" expression="sum(qtddevvenda for group 3) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_2 visible="1" band=trailer.3 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="16271" y="0" height="370" width="1587" format="###,###,##0.000" expression=" sum( QTDSALDORESERVA for group 3) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_4 visible="1" band=trailer.3 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="700" background.mode="1" background.color="536870912" color="33554432" x="17991" y="0" height="370" width="1587" format="###,###,##0.000" expression=" sum( qtddisponivel for group 3) " alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_30 visible="1" band=trailer.4 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" background.mode="1" background.color="536870912" color="33554432" x="17330" y="53" height="370" width="1878" format="###,###,###.000" expression="/* sum(qtddev for group 4) */" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_29 visible="1" band=trailer.4 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" background.mode="1" background.color="536870912" color="33554432" x="14816" y="53" height="370" width="1878" format="###,###,###,###.00" expression="/* sum(valordev for group 4) */" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_28 visible="1" band=trailer.4 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" background.mode="1" background.color="536870912" color="33554432" x="12700" y="79" height="370" width="1905" format="###,###,###.000" expression="/* sum(qtdvend for group 4) */" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
compute(name=compute_26 visible="1" band=trailer.4 font.charset="0" font.face="Arial" font.family="2" font.height="-8" font.pitch="2" font.weight="400" background.mode="1" background.color="536870912" color="33554432" x="10398" y="53" height="370" width="1905" format="###,###,###,###.00" expression="/* sum(valorvenda for group 4) */" alignment="1" border="0" html.valueishtml="0" crosstab.repeat=no )
htmltable(border="1" )
htmlgen(clientComputedFields="1" clientEvents="1" clientFormatting="0" clientScriptable="0" clientValidation="1" encodeSelfLinkArgs="1" generateDDDWFrames="1" generateJavaScript="1" netscapeLayers="0" pagingMethod=0 )
xhtmlgen() cssgen(sessionSpecific="0" )
xmlgen(inline="0" )
xsltgen()
jsgen()
export.xml(headGroups="1" includewhitespace="0" metadatatype=0 savemetadata=0 )
import.xml()
export.pdf(method=0 distill.customPostScript="0" xslfop.print="0" )
export.xhtml()
¿7G¿Foram listados todos os produtos que tiveram movimento tanto de entrada quanto de saída conforme período digitado. Versão: 1¿8H¿SELECT
    ES.IDPRODUTO
    , ES.IDSUBPRODUTO
    , PG.DESCRRESPRODUTO
    , SUM (QTDCOMPRA) AS QTDCOMPRA
    , (
        (SUM (ES.QTDENTRAESTOQUE) - SUM (QTDCOMPRA)) - SUM (QTDDEVVENDA) 
    ) AS QTDOUTRASENTRADAS
    , SUM (QTDDEVCOMPRA) AS QTDDEVCOMPRA
    , SUM (QTDVENDA) AS QTDVENDA
    , SUM (QTDDEVVENDA) AS QTDDEVVENDA
    , RESERVA.QTDDISPONIVEL
    , SALDOINICIAL.QTDSALDOINICIAL
    , SALDOFINAL.QTDSALDOFINAL AS QTDATUALESTOQUE
    , RESERVA.QTDSALDORESERVA
    , SECAO.IDSECAO
    , SECAO.DESCRSECAO
    , GRUPO.IDGRUPO
    , GRUPO.DESCRGRUPO
    , SUBGRUPO.IDSUBGRUPO
    , SUBGRUPO.DESCRSUBGRUPO 
FROM
    (
        SELECT
            ESTOQUE_SINTETICO.IDPRODUTO
            , ESTOQUE_SINTETICO.IDSUBPRODUTO
            , SUM (ESTOQUE_SINTETICO.QTDSALDOINICIAL) AS QTDSALDOINICIAL 
        FROM
            ESTOQUE_SINTETICO 
        WHERE
            DTMOVIMENTO = 
                (
                    SELECT
                        MIN(DTMOVIMENTO) 
                    FROM
                        ESTOQUE_SINTETICO AS ESTOQUE 
                    WHERE
                        ESTOQUE_SINTETICO.IDPRODUTO = ESTOQUE.IDPRODUTO 
                        AND ESTOQUE_SINTETICO.IDSUBPRODUTO = ESTOQUE.IDSUBPRODUTO 
                        AND ESTOQUE_SINTETICO.IDEMPRESA IN (:RA_IDEMPRESA)
                        AND ESTOQUE_SINTETICO.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM 
                )
        GROUP BY
            ESTOQUE_SINTETICO.IDPRODUTO
            , ESTOQUE_SINTETICO.IDSUBPRODUTO 
    ) AS SALDOINICIAL 
    JOIN
        (
            SELECT
                ESTOQUE_SINTETICO.IDPRODUTO
                , ESTOQUE_SINTETICO.IDSUBPRODUTO
                , SUM (ESTOQUE_SINTETICO.QTDATUALESTOQUE) AS QTDSALDOFINAL 
            FROM
                ESTOQUE_SINTETICO 
            WHERE
                DTMOVIMENTO = 
                    (
                        SELECT
                            MAX(DTMOVIMENTO) 
                        FROM
                            ESTOQUE_SINTETICO AS ESTOQUE 
                        WHERE
                            ESTOQUE_SINTETICO.IDPRODUTO = ESTOQUE.IDPRODUTO 
                            AND ESTOQUE_SINTETICO.IDSUBPRODUTO = ESTOQUE.IDSUBPRODUTO 
                            AND ESTOQUE_SINTETICO.IDEMPRESA IN (:RA_IDEMPRESA)
                            AND ESTOQUE_SINTETICO.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM 
                    )
            GROUP BY
                ESTOQUE_SINTETICO.IDPRODUTO
                , ESTOQUE_SINTETICO.IDSUBPRODUTO 
        ) AS SALDOFINAL 
        ON (SALDOINICIAL.IDPRODUTO = SALDOFINAL.IDPRODUTO 
        AND SALDOINICIAL.IDSUBPRODUTO = SALDOFINAL.IDSUBPRODUTO) 
    JOIN
        (
            SELECT
                IDPRODUTO
                , IDSUBPRODUTO
                , SUM (QTDSALDORESERVA) AS QTDSALDORESERVA
                , SUM (QTDDISPONIVEL) AS QTDDISPONIVEL 
            FROM
                PRODUTOS_SALDOS_VIEW PV 
            WHERE
                1 = 1 
                AND PV.IDEMPRESA IN (:RA_IDEMPRESA)
                AND PV.IDPRODUTO IN (:RA_IDSUBPRODUTO)
                AND 1 = 1 
            GROUP BY
                PV.IDPRODUTO
                , PV.IDSUBPRODUTO 
        ) AS RESERVA 
        ON (SALDOFINAL.IDPRODUTO = RESERVA.IDPRODUTO 
        AND SALDOFINAL.IDSUBPRODUTO = RESERVA.IDSUBPRODUTO) 
    JOIN
        ESTOQUE_SINTETICO AS ES 
        ON (RESERVA.IDPRODUTO = ES.IDPRODUTO 
        AND RESERVA.IDSUBPRODUTO = ES.IDSUBPRODUTO) 
    JOIN
        PRODUTO_GRADE AS PG 
        ON (ES.IDPRODUTO = PG.IDPRODUTO 
        AND ES.IDSUBPRODUTO = PG.IDSUBPRODUTO) 
    JOIN
        PRODUTO 
        ON (PG.IDPRODUTO = PRODUTO.IDPRODUTO) 
    JOIN
        SECAO 
        ON (PRODUTO.IDSECAO = SECAO.IDSECAO) 
    JOIN
        GRUPO 
        ON (PRODUTO.IDGRUPO = GRUPO.IDGRUPO) 
    JOIN
        SUBGRUPO 
        ON (PRODUTO.IDSUBGRUPO = SUBGRUPO.IDSUBGRUPO) 
WHERE
    1 = 1 
    AND ES.IDEMPRESA IN (:RA_IDEMPRESA)
    AND ES.IDLOCALESTOQUE IN (:RA_IDLOCALESTOQUE)
    AND GRUPO.IDGRUPO IN (:RA_IDGRUPO)
    AND SUBGRUPO.IDSUBGRUPO IN (:RA_IDSUBGRUPO)
    AND SECAO.IDSECAO IN (:RA_IDSECAO)
    AND ES.IDSUBPRODUTO IN (:RA_IDSUBPRODUTO)
    AND ES.DTMOVIMENTO BETWEEN :RA_DTINI AND :RA_DTFIM 
    AND 1 = 1 
GROUP BY
    ES.IDPRODUTO
    , ES.IDSUBPRODUTO
    , PG.DESCRRESPRODUTO
    , SECAO.IDSECAO
    , SECAO.DESCRSECAO
    , GRUPO.IDGRUPO
    , GRUPO.DESCRGRUPO
    , SUBGRUPO.IDSUBGRUPO
    , SUBGRUPO.DESCRSUBGRUPO
    , SALDOINICIAL.QTDSALDOINICIAL
    , SALDOFINAL.QTDSALDOFINAL
    , RESERVA.QTDSALDORESERVA
    , RESERVA.QTDDISPONIVEL¿9I¿F¿1J¿¿1K¿F¿1L¿¿1M¿¿1N¿¿1O¿¿1P¿¿1Q¿F¿1R¿2¿1S¿F¿1T¿¿1U¿34¿2A¿
||||||||||1	PASTTAB E PASTFIL NÃO EXPORTADOS 14.0
||||||||||7	Estoque	Estoque
||||||||||0	Selecione o tipo de pedido	d_filtro00101	1
1	Informe o tipo de pessoa	d_filtro00236	3
2	Informe o estado ou branco para todos 	d_filtro0012	1
3	Informe o cliente ou branco para todos 	d_filtro0013	1
4	Informe o repositor ou branco para todos	d_filtro0040	1
5	Informe o nº da planilha	d_filtro00326	1
6	Informe o convênio ou branco para todos 	d_filtro0016	1
7	Informe a origem de movimento contábil	d_filtro00118	1
8	Situação do crédito do cliente 	d_filtro0018	1
9	Selecione o tipo do cadastro	d_filtro0019	1
10	Informe o repositor ou branco para todos	d_filtro00121	1
11	Informe o tipo de produto a filtrar 	d_filtro0022	1
12	Informe o produto ou branco para todos 	d_filtro0023	1
13	Informe o código final do cliente	d_filtro00326	1
14	Informe o local de estoque que será abastecido	d_filtro00124	1
15	Informe a promoção	d_filtro00142	1
16	Informe o nº de dias inicial	d_filtro00289	1
17	Imprimir somente itens pesáveis 	d_filtro0028	1
18	Informe o nº de dias final	d_filtro00289	1
19	Informe a empresa 	d_filtro0061	1
20	Informe o nº do balanço ou zero para todos	d_filtro00326	1
21	Digite o período para a data de vencimento 	d_filtro0033	1
22	Digite o período para a data de movimento 	d_filtro0033	1
23	Digite o período para a data de pagamento 	d_filtro0033	1
24	Informe a(s) forma(s) de pagto ou branco p/ todas 	d_filtro0036	1
25	Informe a versão	d_filtro00423	3
26	Data da release inicial	d_filtro00321	1
27	Informe o local de estoque repositor	d_filtro00124	1
28	Informe o fornecedor ou branco para todos	d_filtro0013	1
29	Data da release final	d_filtro00322	1
30	Informe a localização ou branco para todas	d_filtro_depart	1
31	Informe a atividade ou branco para todas	d_filtro00111	1
32	Informe o valor da hora cobrado	d_filtro00327	1
33	Informe o vendedor ou branco para todos 	d_filtro00126	1
34	Informe a região ou branco para todos 	d_filtro00114	1
35	Informe o(s) subgrupo(s) ou branco para todos 	d_filtro00210	1
36	Informe o(s) grupo(s) ou branco para todos 	d_filtro00211	1
37	Informe a(s) seção(ões) ou branco para todos 	d_filtro00212	1
38	Informe o avalista ou branco para todos	d_filtro0013	1
39	Informe o componente ou branco para todos	d_filtro_componente	3
40	Informe a categoria da operação interna	d_filtro_categoriacoi	4
41	Informe a série ou branco para todas	d_filtro00115	6
42	Vencidas, a vencer ou ambas	d_filtro00149	11
43	Informe o dia do aniversário	d_filtro0032	3
44	Informe o mês do aniversário	d_filtro0042	3
45	Informe o bairro ou branco para todos 	d_filtro00115	1
46	Informe a cidade ou branco para todos 	d_filtro00116	1
47	Informe a alíquota 	d_filtro00229	1
48	Informe o n° da conta bancária	d_filtro00411	5
49	Informe o banco ou branco para todos	d_filtro00117	3
50	Informe o COI ou branco para todos 	d_filtro00119	1
51	Informe o local de estoque ou branco para todos 	d_filtro00124	1
52	Informe o código suframa	d_filtro00115	4
53	Informe o estado civil	d_filtro00122	1
54	Informe o n° do pedido	d_filtro00326	5
55	Informe o cliente / fornecedor ou branco para todos	d_filtro0013	1
56	Informe o endereço ou branco para todos	d_filtro00115	1
57	Informe o tipo de residência	d_filtro00128	1
58	Informe o Nº da CONDICIONAL	d_filtro00326	3
59	Informe o nº da pré-venda	d_filtro00115	4
60	Data/hora de movimento inicial	d_filtro00140	5
61	Data/hora de movimento final	d_filtro00140	3
62	Informe o estado	d_filtro0012	3
63	Informe a quantidade de produtos	d_filtro00326	3
64	Data final	d_filtro00322	1
65	Data inicial	d_filtro00321	1
66	Selecione o tipo da nota fiscal	d_filtro00413	1
67	Informe o subproduto ou branco para todos 	d_filtro0023	1
68	Data para posição	d_filtro00322	1
69	Informe o cliente	d_filtro0013	3
70	Data incio faturamento	d_filtro00321	3
71	Informe o item mestre ou branco para todos	d_filtro0023	1
72	Data final faturamento	d_filtro00322	3
73	Informe o nº de dias 	d_filtro00289	1
74	Informe a situação do pedido	d_filtro00432	3
75	Informe o nº da nota ou branco para todos	d_filtro00326	1
76	Informe o usuário ou branco para todos	d_filtro00430	1
77	Informe o cobrador ou branco para todos	d_filtro0013	4
78	Informe a situação do agendamento	d_filtro00433	4
79	Informe o nº do cupom ou branco para todos	d_filtro00326	1
80	Informe o nº do caixa ou branco para todos 	d_filtro00326	1
81	Data de movimento	d_filtro00322	2
82	Informe o estado de origem	d_filtro0012	3
83	Período por atraso	d_filtro00150	4
84	Data de cancelamento inicial	d_filtro00321	1
85	Informe o(s) usuário(s) ou branco para todos	d_filtro00430	4
86	Data de aniversário inicial	d_filtro00321	1
87	Data de aniversário final	d_filtro00322	1
88	Pendentes, liquidadas ou ambas	d_filtro00130	1
89	Somente venda a vista	d_filtro0131	1
90	Informe o nº do orçamento ou branco para todos	d_filtro00326	1
91	Exibir somente titulos liquidados de origem	d_filtro00326	1
92	Data de vencimento inicial	d_filtro00321	1
93	Data de vencimento final	d_filtro00322	1
94	Tipo nota / cupom / ambas	d_filtro_notacupom	1
95	Tipo nota / cupom / ambas	d_filtro_notacupom	1
96	Tipo nota, cupom, ambas	d_filtro_notacupom	1
97	Desconto acima de	d_filtro00131	1
98	Informe o sistema	d_filtro00421	1
99	Informe o fabricante / marca ou branco para todos 	d_filtro00115	3
100	Informe o kit ou branco para todos	d_filtro002401	1
101	Informe a conta bancária	d_filtro00132	1
102	Período de data de nascimento	d_filtro00431	1
103	Período de data de nascimento	d_filtro00431	1
104	Data de pagamento inicial	d_filtro00321	1
105	Data de pagamento final	d_filtro00322	1
106	Digite a instituição (administradora)	d_filtro00115	1
107	Tipo da transação	d_filtro0060	1
108	Informe o nº de pontos (por R$1,00 vendido)	d_filtro00131	1
109	Informe a conta contábil	d_filtro00133	1
110	Informe o tipo situação tributária 	d_filtro00240	1
111	Situação atual do cheque	d_filtro00241	1
112	Informe atraso acima de x dias 	d_filtro00289	1
113	Informe o nº do pedido ou branco para todos	d_filtro00326	1
114	Transportador ou branco para todos	d_filtro0013	1
115	Informe o nº da página inicial	d_filtro00289	1
116	Informe a data de vencimento inicial	d_filtro00321	1
117	Informe a data de vencimento final	d_filtro00322	1
118	Quantidade inicial de estoque	d_filtro00327	1
119	Quantidade final de estoque	d_filtro00327	1
120	Data previsão de entrega inicial	d_filtro00321	1
121	Data previsão de entrega final	d_filtro00322	1
122	Data de emissão inicial	d_filtro00321	1
123	Data de emissão final	d_filtro00322	1
124	Data de retirada inicial	d_filtro00321	1
125	Data de retirada final 	d_filtro00322	1
126	Informe o custo por km rodado	d_filtro00327	1
127	Adiantamentos	d_filtro00134	1
128	Somente adiantamentos a	d_filtro00191	1
129	Data de movimento inicial	d_filtro00321	1
130	Data de movimento final	d_filtro00322	1
131	Selecione o módulo	d_filtro0050	1
132	Data inicial do último log 	d_filtro00321	1
133	Data final do último log	d_filtro00322	1
134	Informe o funcionário ou branco para todos	d_filtro0013	1
135	Tipo de alteração de preço	d_filtro00135	1
136	Preços zerados e/ou não	d_filtro00136	1
137	Preços em promoção e/ou não	d_filtro00137	1
138	Grupo ou zero para todos	d_filtro00211	1
139	Subgrupo ou zero para todos	d_filtro00210	1
140	Forma(s) de pagamento ou zero para todos	d_filtro0036	1
141	Situação de vendas futuras	d_filtro00138	1
142	Situação do cadastro do produto ativo/inativo	d_filtro00139	1
143	Quantidade de produtos	d_filtro00323	1
144	Data/hora previsão de entrega inicial	d_filtro00140	1
145	Data/hora previsão de entrega final	d_filtro00141	1
146	Situação do cnpj/cpf dos clientes	d_filtro00142	1
147	Data de alteração inicial	d_filtro00321	1
148	Data de alteração final	d_filtro00322	1
149	Digite a descrição parcial do item	d_filtro00115	1
150	Informe o tipo de categoria	d_filtro5000	1
151	Data de balanço	d_filtro00322	1
152	Situação de pis/cofins	d_filtro00143	1
153	Informe o nº da carga	d_filtro00326	1
154	Informe o processo ou branco para todos	d_filtro00144	1
155	Informe o tipo do preço	d_filtro00145	1
156	Data inicial da primeira faixa de horário	d_filtro00321	1
157	Data final da primeira faixa de horário	d_filtro00322	1
158	Data inicial da segunda faixa de horário	d_filtro00321	1
159	Data final da segunda faixa de horário	d_filtro00322	1
160	Informe a(s) empresa(s)	d_filtro0031	1
161	Tipo de cálculo do pis/cofins	d_filtro00146	1
162	Informe o tipo de emissão	d_filtro00147	1
163	Data de promoção inicial	d_filtro00321	1
164	Data de promoção final	d_filtro00322	1
165	Situação do cadastro do cliente ativo/inativo	d_filtro00139	1
166	Informe o departamento ou branco para todos	d_filtro_depart	1
167	Data de cancelamento final	d_filtro00322	1
168	Informe o indicador ou branco para todos	d_filtro0013	1
169	Informe o % de bonificação	d_filtro00131	1
170	Data de validade inicial	d_filtro00321	1
171	Data de validade final	d_filtro00322	1
172	Informe o nº do chamado	d_filtro00326	1
173	Informe a gerência ou branco para todos	d_filtro0013	1
174	Informe o responsável ou branco para todos	d_filtro0013	1
175	Informe dias de cadastro maior que	d_filtro00289	1
176	Informe dias do último movimento maior que	d_filtro00289	1
177	Informe a categoria do chamado	d_filtro00115	1
178	Informe a situação do chamado	d_filtro00115	1
179	Informe o agente ou branco para todos	d_filtro0013	1
180	Informe o cep ou branco para todos	d_filtro00125	1
181	Informe o módulo	d_filtro0050	1
182	Data inicial da validade reserva	d_filtro00321	1
183	Data final da validade reserva	d_filtro00322	1
184	Informe o tipo da situação 	d_filtro00250	1
185	Infome o nº da nota inicial	d_filtro00326	1
186	Informe o nº da nota final	d_filtro00326	1
187	Pendentes, baixados ou ambos	d_filtro00148	1
188	Data de abertura do chamado inicial	d_filtro00321	1
189	Data de abertura do chamado final	d_filtro00322	1
190	Informe a transportadora	d_filtro0013	1
191	Data de balanço inicial	d_filtro00321	1
192	Data de balanço final	d_filtro00322	1
193	Informe a administradora	d_filtro0066	1
194	Informe o código final do cliente	d_filtro00326	1
195	Informe o patrimônio	d_filtro0065	1
196	Informe o modelo ou branco para todos 	d_filtro00115	1
197	Informe o nº da cotação	d_filtro00326	1
198	Informe o nº da condicional	d_filtro00326	1
199	Informe o nº do cupom fiscal	d_filtro00326	1
200	Informe o valor mínimo de ir	d_filtro00131	3
201	Porcentagem p/ impressão	d_filtro00131	3
202	Data de cadastro inicial	d_filtro00321	4
203	Data de cadastro final	d_filtro00322	4
204	Situação da duplicata	d_filtro0051	3
205	Informe o autorizado ou branco para todos	d_filtro0067	3
206	Informe o tipo de custo	d_tipo_custo	5
207	Data de cobrança inicial	d_filtro00321	2
208	Data de cobrança final	d_filtro00322	2
209	Informe a cadeia de preços	d_filtro_cadeiapreco	3
210	Quantidade de fornecedores a listar	d_filtro00326	4
211	Informe o comprador ou branco para todos	d_filtro00430	3
212	Informe a quantidade inicial de venda ou branco todas	d_filtro00326	4
213	Observação de retirada do produto	d_filtro_obsproduto	3
214	Informe a senha do vendedor   	d_filtro00115	8
215	Informe a codificação dos relatórios de invetário	d_filtro00215	5
216	Informe o vendedor	d_filtro00126	2
217	Informe o local de retirada	d_filtro00217	2
218	Informe o período para a data de promoção	d_filtro0033	4
219	Data fim de promoção inicial	d_filtro00321	4
220	Data fim de promoção final	d_filtro00322	5
221	Informe o Fornecedor	d_filtro0013	2
222	Informe a situação de nota de transferência	d_filtro_situacao_nota	2
223	Listar somente clientes que pontuam	d_filtro0028	5
224	Informe o número da nota	d_filtro00326	2
225	Livro Fiscal	d_filtro00225	2
226	Somente produtos que possuem lote	d_filtro0028	2
227	Informe o(s) COI(s) ou branco para todos 	d_filtro00120	3
228	Informe a situação da transação	d_filtro00228	3
229	Preço default	d_tipo_valor	19
230	Informe o orçamento	d_filtro00326	2
231	Informe a empresa atual	d_filtro0061	2
232	Informe o(s) usuário(s)	d_filtro00430	2
233	Mostrar somente produtos com saldo de estoque	d_filtro00233	2
234	Pendentes, liquidados ou ambos	d_filtro00234	3
235	Informe o fabricante / marca	d_filtro00115	4
236	Mostrar lotes com data validade	d_filtro00237	4
237	Informe a data de validade dos lotes	d_filtro00238	5
238	Informe o % para comissão	d_filtro00131	4
239	Somente produtos com icms garantido integral	d_filtro0028	3
240	Informe a situação do patrimônio	d_filtro240	10
241	Custo para a valorização da diferença	d_filtro0241	2
242	Informe o número de dias para sugestão de compras	d_filtro00289	4
243	Informe o % de deflação	d_filtro00243	3
244	Somente produtos com sugestão de compras	d_filtro0028	5
245	Informe o índice de correção	d_filtro00255	3
246	Percentual de acréscimo a ser aplicado	d_filtro00256	2
247	Informe o(s) coi(s)	d_filtro00120	3
248	Compra, venda ou ambas 	d_filtro00300	3
249	Informe o corredor ou branco para todos	d_filtro00326	2
250	Informe o corredor	d_filtro00411	2
251	Situação	d_filtro00148	4
252	Tipo de cálculo do pis/cofins	d_filtro00201	2
253	Gôndola (ou branco para todas)	d_filtro00200	3
254	Prateleira (ou branco para todas)	d_filtro00200	3
255	Informe o código da família	d_filtro00210	2
256	Data inicial período anterior	d_filtro00321	3
257	Chamado externo pago	d_filtro00257	3
258	Data final período anterior	d_filtro00322	3
259	Buscar produtos com icms garantido integral	d_filtro00257	2
260	Informe a família	d_filtro00210	7
261	Informe a(s) divisão(ões) ou branco para todos	d_filtro00561	5
262	Informe o mês	d_filtro_mes	3
263	Informe o ano	d_filtro_ano	3
264	Informe o local de est. p/ troca ou branco para todos	d_filtro00125	2
265	Data inicial (remessa)	d_filtro00321	3
266	Data inicial (venda futura)	d_filtro00321	2
267	Data final (venda futura)	d_filtro00322	3
268	Informe o nº nota venda	d_filtro00326	2
269	Informe o nº nota remessa	d_filtro00326	2
270	Informe o tamanho do produto	d_filtro00127	2
271	Informe a descrição do cabeçalho 	d_filtro00115	4
272	Informe a empresa 1	d_filtro0061	4
273	Informe a empresa 2	d_filtro0061	2
274	Informe o local de estoque 1	d_filtro00124	2
275	Informe o local de estoque 2	d_filtro00124	2
276	Informe o tipo	d_filtro00276	2
277	Informe o modelo	d_filtro00277	2
278	Informe o grupo econômico	d_filtro_grupo_economico	4
279	Informe o total de registros a serem listados	d_filtro00289	2
280	Informe o local de estoque a ser ignorado	d_filtro00124	2
281	Informe o 1º local de estoque	d_filtro00124	2
282	Informe o 2º local de estoque	d_filtro00124	2
283	Informe a 1ª empresa	d_filtro0061	2
284	Informe a 2ª empresa	d_filtro0061	2
285	Informe o nº da o.s.	d_filtro00326	3
286	Informe o numsequencia inicial	d_filtro00289	2
287	Informe o numsequencia final	d_filtro00289	2
288	Destino da chave	d_filtro00436	2
289	Chave gerada por	d_filtro00437	2
290	Informe o(s) grupos de usuário(s) ou branco todos 	d_filtro00430	3
291	Informe a alíquota de entrada	d_filtro00229	4
292	Informe a alíquota de saída	d_filtro00229	6
293	Informe as divisões ou branco para todas	d_filtro00335	2
294	Margem 1	d_filtro00243	3
295	Margem 2	d_filtro00243	3
296	Margem 3	d_filtro00243	2
297	Margem 4	d_filtro00243	3
298	Margem 5	d_filtro00243	2
299	Informe a quantidade inicial de venda ou branco todas (1° período)	d_filtro00326	2
300	Informe a quantidade inicial de venda ou branco todas (2° período)	d_filtro00326	2
301	Informe o % de juro	d_filtro00131	2
302	Informe o(s) subproduto(s) ou branco para todos	d_filtro0561	2
303	Situação da ordem de serviço	d_filtro00151	2
304	Informe o nº da ordem de serviço	d_filtro00152	4
305	Informe o responsável	d_filtro00430	3
306	Informe o motivo do cancelamento do contrato	d_filtro_subcategoria	4
307	Data do evento	d_filtro00322	2
308	Informe a lista ou branco para todas	d_filtro_lista_presente	3
309	Informe a situacao da lista	d_filtro_situacao_lista	2
310	Data do evento inicial	d_filtro00321	2
311	Data do evento final	d_filtro00322	2
312	Informe a localização do patrimonio	d_filtro00291	2
313	Informe o grupo econômico	d_filtro_grupo_economico	2
314	Informe o tipo da mercadoria ou branco para todos	d_filtro_tipo_mercadoria_sefaz	2
315	Informe a quantidade mínima de estoque	d_filtro_quant_minima_estoque	3
316	Informe a data de levantamento do estoque	d_filtro_data_levantamento_estoque	3
317	Informe o(s) grupo(s)	d_filtro00211	4
318	Informe o grupo fluxo	d_filtro00445	2
319	Jan	d_filtro00131	2
320	Informe o status do módulo	d_filtro0068	2
321	Informe a bancada	d_filtro00211	4
322	Informe a situação atual do cheque	d_filtro_situacao_cheque	2
323	Informe o número da encomenda	d_filtro00446	3
324	Produtos em promoção:	d_filtro00207	3
325	Tipo pessoa	d_filtro00209	2
326	Informe o motivo da devolução	d_filtro00115	2
327	Informe o status do pedido	d_filtro00214	2
328	Informe o fornecedor 2	d_filtro0013	3
329	Informe o fornecedor 3	d_filtro0013	2
330	Informe o Fornecedor 4	d_filtro0013	2
331	Informe o modulo do Sistema	d_filtro0052	2
332	Informe o nº do Vão ou branco para todos	d_filtro00326	4
333	Informe a área	d_filtro00447	2
334	Informe a bonificação	d_filtro00326	2
335	Informe a(s) forma(s) de pagto que não deve listar	d_filtro0036	3
336	Informe o n° do CFOP	d_filtro00326	3
337	Somente Locais de Estoque Central de Compras	d_filtro_locais_est_central_compras	3
338	Somente Produtos com Pré-Pedido(s) Pendente(s)	d_filtro_produto_pendente_prepedido	2
339	Informe o representante	d_filtro00562	2
340	Status da negociação	d_filtro00563	3
341	Tipo do preço	d_filtro00564	2
342	Prazo da negociação	d_filtro00565	2
343	Informe a série	d_filtro00566	2
344	Informe a(s) atividade(s) ou branco para todas	d_filtro00344	2
345	Informe o nº do pré-pedido ou branco para todos	d_filtro_nro_prepedido	2
346	Situação do(s) Pré-Pedido(s)	d_filtro_situacao_prepedido	2
347	Informe o Associado ou branco para todos	d_filtro0013	3
348	Informe o Fornecedor ou branco para todos	d_filtro0013	2
349	Informe o nº da autorização	d_filtro00229	2
350	Informe o tipo do Regime	d_filtro00350	3
351	Informe a(s) Cta(s) Contábil(s) ou branco p/ todos	d_filtro00439	5
352	Tipo de Preço Pré-Pedido	d_filtro_tipo_preco_prepedido	2
353	Situação do Clientes	d_filtro0018	4
354	Informe o tipo regime ou branco para todos	d_filtro00350	2
355	Empresa(s) destino ou branco para todos	d_filtro0031	3
356	Tipo da Nota de Transferência	d_filtro00356	2
357	Informe o tipo de Movimento	d_filtro00448	4
358	Informe a origem	d_filtro00358	3
359	Subproduto(s) ou branco para todos	d_filtro0561	6
360	Informe o nome do atendente ou branco para todos	d_filtro00115	2
361	Avaliação do atendente	d_filtro00361	3
362	Avaliação da ferramenta de atendimento	d_filtro00361	2
363	Informe a célula de atendimento ou branco p/ todas	d_filtro00115	4
364	Informe a(s) nota(as) ou branco para todas	d_filtro00115	6
365	Tipo encomenda	d_filtro00451	2
366	Informe o nº da abertura	d_filtro00326	3
367	Informe o código inicial do cliente	d_filtro00326	1
368	Informe a situação do crédito do cliente 	d_filtro0018	1
369	Informe o % de divergencia	d_filtro00243	3
370	Informe o(s) COI de saída 1	d_filtro00120	6
371	Informe o(s) COI de saída 2	d_filtro00120	6
372	Informe a bancada	d_filtro_bancada	2
373	Informe o(s) grupos de usuário(s) ou branco todos 	d_filtro00430	3
374	Informe o(s) cois de entrada	d_filtro00120	2
375	Informe o local de estoque origem	d_filtro00124	3
376	Informe o local de estoque destino	d_filtro00124	2
377	Informe a prioridade de entrega	d_filtro00289	2
378	Tipo solicitação	d_filtro00155	2
379	Data de fechamento inicial	d_filtro00321	2
380	Data de fechamento final	d_filtro00322	2
381	Informe o produtivo ou branco todos	d_filtro00430	3
382	Informe o período para a data de vencimento 	d_filtro0033	2
383	Data inicial do 1º periodo	d_filtro00321	3
384	Data final do 1º periodo	d_filtro00322	3
385	Data inicial do 2º periodo	d_filtro00321	3
386	Data final do 2º periodo	d_filtro00322	4
387	1º data para posição de estoque	d_filtro00322	2
388	2º data para posição de estoque	d_filtro00322	2
389	Situação pis/cofins	d_filtro00568	2
390	Situação tributária	d_filtro00569	2
391	Origem	d_filtro00570	3
392	Data de produção inicial	d_filtro00321	2
393	Data de produção final	d_filtro00322	3
394	Informe o % de margem inicial	d_filtro00131	2
395	Informe o % de margem final	d_filtro00131	3
396	Informe o % de variação de custo inicial	d_filtro00131	4
397	Informe o % de variação de custo final	d_filtro00131	2
398	Digite a observação	d_filtro00571	2
399	Quantidade de produtos por divisão a listar	d_filtro00326	4
400	Informe o nº nota remessa	d_filtro00326	2
401	Informe a empresa de produção	d_filtro0031	6
402	Informe o nº do caixa que não deve mostrar 	d_filtro00326	4
403	Compra, Venda	d_filtro_tipomovimento	3
404	Informe a situacao do chamado	d_filtro_situacao_chamado	2
405	Listar somente produtos com divergência	d_filtro0028	3
406	Informe os nº(s) da(s) nota(s) ou branco para todas	d_filtro00345	2
407	Informe a categoria do COI ou branco para todas	d_filtro_categoriacoitodas	6
408	Mostra títulos da tesouraria	d_filtro00438	3
409	Chave teste ciss	d_filtro_situacao_chamado	3
410	Situação do pedido	d_filtro00410	4
411	Informe a Alinea do Chque ou branco pra todas	d_filtro0071	3
412	Situação da bonifiacação	d_filtro0562	3
413	Tipo da Bonificação	d_filtro0563	3
414	Informe o nº da encomenda ou branco para todos	d_filtro00326	4
415	Informe a rede de negócios	d_filtro_rede_negocio	2
416	Informe o ponto de retirada ou branco para todos	d_filtro_pontoretiradabranco	4
417	Informe a situação da entrega	d_filtro_situacaologistica	3
418	Informe o tipo da data	d_filtro_tipo_data	2
419	Informe a conta contábil (crédito) de troco	d_filtro00133	4
420	Informe a conta contábil (crédito)  de contra-vale	d_filtro00133	4
421	Informe o n° da DAV ou branco para todos	d_filtro00326	3
422	Informe o n° do DAV	d_filtro00326	3
423	Informe o Projeto	d_filtro_projeto	2
424	Classificação(ões) contábil(eis) ou branco p/ todas	d_filtro00440	4
425	Informe o tipo de pesquisa	d_filtro_ven_ind	2
426	Informe o tipo da pesquisa	d_filtro_ven_ind	2
427	Informe o(s) local(is) de estoque	d_filtro00575	2
428	Informe a bandeira	d_filtro_bandeira	3
429	Informa o número da remessa	d_filtro00566	2
430	Informe a situação de cobrança	d_filtro_situacao_cobranca	3
431	Informe o gerente ou branco para todos	d_filtro0013	3
432	Imprimir a marca dos produtos	d_filtro0028	2
433	Informe o código da separação	d_filtro00326	3
434	Informe o histórico contábil	d_filtro_historico_contabil	3
435	Fabricante / Marca ou branco para todos	d_filtro_pesquisa_marca	4
436	Informe a situação de cobrança	d_filtro_situacao_cobranca	5
437	Informe o período para a data de movimento 	d_filtro0033	2
438	Informe o período para a data de pagamento 	d_filtro0033	2
439	Informe o fidelizado ou branco para todos	d_filtro0067	4
440	Informe o número da autorização	d_filtro00326	2
441	Tipo de movimento	d_filtro00413	3
442	Somente serviços	d_filtro_flagIss	3
443	Informe o COI de PIS/COFINS	d_filtro_busca_coi_piscofins	4
444	Informe o nº do caixa	d_filtro00326	1
445	Tipo classificação	d_filtro_classificacao_ctba	2
446	Tipo Auxilio	d_filtro_auxilio	2
447	Informe a situação atual dos cheques	d_filtro_situacao_atual_cheque	3
448	Informe a campanha	d_filtro_campanha_promocional	2
449	Informe o cobrador	d_filtro_cobrador	2
450	Informe o operador ou branco para todos	d_filtro00430	2
451	Informe o(s) orçamento(s)	d_filtro00452	7
452	Informe a(s) notas(s) fiscais	d_filtro00452	5
453	Informe a situação das vendas futuras 	d_filtro00453	4
454	Situação notas	d_filtro_notas_servico_canceladas	2
455	Informe o nº do cfop	d_filtro_cfop	3
456	Informe o % de juro	d_filtro00131	2
457	Tipo relatório	d_filtro00457	3
458	Clientes cadastrados	d_filtro00207	3
459	Produtos com sugestão de compras	d_filtro00576	2
460	Tipo	d_filtro00577	1
461	Informe o nª da nota/cupom fiscal	d_filtro00326	3
462	Release	d_filtro00115	3
463	Somente notas com divergência	d_filtro0028	4
464	Versão	d_filtro00566	2
465	Informe o(s) ncm(s) ou branco para todos	d_filtro_ncm	3
466	% mva	d_filtro00243	3
467	% Alíquota interna	d_filtro_aliquota_interna	4
468	Tipo de custo	d_filtro0241	2
469	Ordenar por	d_filtro_ordem_razao	3
470	Manifesto(s)	d_filtro00578	4
471	Informe o veículo	d_filtro_veiculo	2
472	Informe o motorista	d_filtro0013	2
473	Nª do registro de entrada	d_filtro00289	2
474	Nª do registro de saída	d_filtro00289	2
475	Melhorias	d_filtro00257	6
476	Informe o(s) ponto(s) de retirada	d_filtro00579	2
477	Situação do Estoque	d_filtro00580	2
478	Informe o local de estoque 	d_filtro00124	1
479	Situação	d_filtro00139	1
480	Dias para cálculo da média diária de venda	d_filtro00289	2
481	Dias para cálculo de excesso	d_filtro00289	2
482	Tipo nota / cupom / ambas	d_filtro00326	1
483	Dias para cálculo de faltas	d_filtro00289	2
484	Ativo / inativo para compra	d_filtro00139	1
485	Considerar acréscimos no cálculo da comissão	d_filtro0028	1
486	Informe o nº da Pré-Carga	d_filtro00326	2
487	Subtrair as devoluções	d_filtro00233	2
488	Situação cheques conciliados	d_filtro00581	2
489	Tipo de Entrega	d_filtro00582	4
490	Informe o regime federal	d_filtro00583	2
491	Selecione o grupo de patrimônios	d_filtro00491	2
492	Informe o nº do pedido de venda	d_filtro00326	5
493	Informe o tipo do patrimônio	d_filtro00584	3
494	Informe o número do livro	d_filtro00326	2
495	Considerar produtos configurados como patrimônio	d_filtro00233	4
496	Informe a(s) cesta(s) ou branco para todas	d_filtro0561	2
497	Formas de pagamento à vista	d_filtro00257	3
498	Situação do cliente no cartão próprio ativo/inativo	d_filtro00139	4
499	Tipo de cartão (débito/crédito/ambos)	d_filtro0060	2
500	Informe o(s) usuário(s) que não deve mostrar	d_filtro00430	2
501	Somente cadastros alterados	d_filtro00576	2
502	Data inicial do 3º periodo	d_filtro00321	3
503	Data final do 3º periodo	d_filtro00322	2
504	Valor inicial	d_filtro00327	2
505	Valor Final	d_filtro00327	2
506	Release	d_filtro00115	3
507	Somente notas com divergência	d_filtro0028	4
508	Versão	d_filtro00566	2
509	Informe o(s) ncm(s) ou branco para todos	d_filtro_ncm	3
510	% mva	d_filtro00243	3
511	% Alíquota interna	d_filtro_aliquota_interna	4
512	Tipo de custo	d_filtro0241	2
513	Ordenar por	d_filtro_ordem_razao	3
514	Manifesto(s)	d_filtro00578	4
515	Informe o veículo	d_filtro_veiculo	2
516	Informe o motorista	d_filtro0013	2
517	Nª do registro de entrada	d_filtro00289	2
518	Nª do registro de saída	d_filtro00289	2
519	Melhorias	d_filtro00257	6
520	Informe o(s) ponto(s) de retirada	d_filtro00579	2
521	Situação do Estoque	d_filtro00580	1
522	Informe o local de estoque 	d_filtro00124	1
523	Situação	d_filtro00139	1
524	Dias para cálculo da média diária de venda	d_filtro00289	2
525	Dias para cálculo de excesso	d_filtro00289	2
526	Tipo nota / cupom / ambas	d_filtro00326	1
527	Dias para cálculo de faltas	d_filtro00289	2
528	Ativo / inativo para compra	d_filtro00139	1
529	Considerar acréscimos no cálculo da comissão	d_filtro0028	1
530	Somente cadastros alterados	d_filtro00576	2
531	Informe o produto	d_filtro00326	4
532	Informe a dat inicial	d_filtro00238	3
533	Informe o nº da nota/cupom fiscal	d_filtro00326	3
534	Informe o repositor ou branco para todos	d_filtro0040	1
535	Situação do crédito do cliente 	d_filtro0018	1
536	Situação atual do cheque	d_filtro00241	1
537	Situação de vendas futuras	d_filtro00138	1
538	Pendentes, baixados ou ambos	d_filtro00148	1
539	Informe a quantidade minima de giro	d_filtro00326	2
540	Informe o % de divergencia	d_filtro00131	2
541	Informe o COI de Saída 1	d_filtro00119	4
542	Informe o COI de Saída 2	d_filtro00119	4
543	Informe a prioridade de entrega	d_filtro00326	3
544	Somente serviços	d_filtro_flagIss	3
545	Informe o nª do manifesto	d_filtro00326	2
546	Tipo nota/cupom/ambas	d_filtro00326	1
547	Informe o nº da Pré-Carga	d_filtro00326	2
548	Subtrair as devoluções	d_filtro00233	2
549	Informe o(s) NCM(s)	d_filtro00577	1
550	Situação cheques conciliados	d_filtro00581	2
551	Tipo de Entrega	d_filtro00582	4
552	Pesquisar por nª	d_filtro00578	2
553	Este foi para teste	d_filtro00115	
554	Informe o tipo de promoção	d_filtro00142	
555	Informe a localização do patrimonio	d_filtro0070	8
556	Inform a situação do produto	d_filtro00333	2
557	Informe o n° do cheque	d_filtro00329	3
558	Informe a data inicial do primeiro período	d_filtro00321	2
559	Informe a data final do primeiro período	d_filtro00322	2
560	Informe a data inicial do segundo período	d_filtro00321	2
561	Informe a data final do segundo período	d_filtro00322	2
562	Informe a(s) divisão(ões) ou branco para todas	d_filtro00213	4
563	Situação do cadastro de produto novo/reativado	d_filtro00334	1
564	Somente departamento comercial	d_filtro0028	2
565	Informe a instituição (administradora)	d_filtro00115	2
566	Informe o tipo da transação	d_filtro0060	2
567	Informe a situação atual do cheque	d_filtro00241	1
568	Informe o transportador ou branco para todos	d_filtro0013	2
569	Informe a quantidade inicial de estoque	d_filtro00327	2
570	Informe a quantidade final de estoque	d_filtro00327	2
571	Informe o tipo de alteração de preço	d_filtro00135	2
572	Informe a situação de vendas futuras	d_filtro00138	1
573	Informe a descrição parcial do item	d_filtro00115	2
574	Informe a categoria do(s) chamado(s)	d_filtro5000	6
575	Informe o tipo de cálculo do PIS/COFINS	d_filtro00146	2
576	Informe parte da descrição da categoria do chamado	d_filtro00115	2
577	Informe parte da descrição da situação do chamado	d_filtro00115	2
578	Informe o nº da nota inicial	d_filtro00326	2
579	Informe a situação dos chamados pendentes/baixados	d_filtro00148	1
580	Informe o comprador ou branco todos	d_filtro00430	2
581	Selecione o Grupo de Patrimônios	d_filtro00581	1
582	Informe a(s) divisão(ões) ou branco para todos	d_filtro00211	2
583	Informe o(s) ncm(s)	d_filtro00115	2
584	Informe a empresa 	d_filtro0031	1
585	Tipo de cálculo do pis/cofins	d_filtro00201	2
586	Data final (remessa)	d_filtro00322	5
587	Informe a situação do patrimonio	d_filtro00290	4
588	Informe o(s) subproduto(s) ou branco para todos	d_filtro00561	2
589	Informe o autorizado ou branco para todos	d_filtro0067	3
590	Informe a codificação dos relatórios de inventário	d_filtro00215	6
591	Informe o tipo de movimento	d_filtro00448	4
592	Informe a(s) forma(s) de pagto ou branco  p/ todas	d_filtro0036	4
593	Informe o tipo 	d_filtro00236	3
594	Informe a Data para auditoria de preços alterados 	d_filtro00215	
595	Preços alterados depois de  	d_filtro00216	
596	Preços não alterados desde	d_filtro00217	
597	Somente itens que permite venda negativa 	d_filtro00218	
598	Informe o período para data de início de promoção 	d_filtro0033	
599	Produtos exportáveis para frente de caixa 	d_filtro00230	
600	Data de digitação inicial	d_filtro00321	2
601	Data de digitação final	d_filtro00322	2
602	Informe o(s) ncm(s)	d_filtro00577	1
603	Data inicial de aquisição	d_filtro00321	1
604	Data final de aquisição	d_filtro00322	1
605	Somente produtos ativos	d_filtro00231	
606	Informe o vendedor ou branco para todos 	d_filtro00121	
607	Numero de dias	d_filtro00232	
608	N dias	d_filtro003234	
609	Informe os  produtos desejados	d_filtro0023	
610	Informe a data final da promoção	d_filtro00219	
611	Informe a data inicial	d_filtro00321	
612	Informe a data final	d_filtro00322	
613	Informe a seção ou 0 (zero) para todos	d_filtro00212	
614	Data de movimento	d_filtro0017	
615	Digíte o periodo para a data de pagamento	d_filtro0017	
616	Informe o dia de nascimento	d_filtro00400	
617	Informe o mês de nascimento	d_filtro00401	
618	Informe uma seção	d_filtro00212	
619	Informe um grupo	d_filtro00211	
620	informe um subgrupo	d_filtro00210	
621	Seção ou 0 para todas 	d_filtro00234	
622	Informe a senha do usuário do Vendedor	d_filtro_senha	10
623	Informe a localização do patrimônio	d_filtro_localizacaopatrimonio	5
624	Informe a orientação do papel	d_filtro00252	2
625	Informe a marca ou branco para todos	d_filtro00129	5
626	Informe a batatinha 	d_filtro0061	1
627	Informe a batatinha 	d_filtro00289	1
628	Informe forma(s) de pagto(s) ou branco para todas	d_filtro0036	6
629	Informe o tipo de 	d_filtro00236	3
630	Empresa(s) retirada	d_filtro0031	6
631	Empresa(s) origem	d_filtro0031	2
632	Informe a senha do vendedor	d_filtro_senha	12
633	Informe aa pessoa	d_filtro00236	3
634	Informe 	d_filtro0012	3
635	Informe a qtde inicial de venda ou branco para todos	d_filtro00326	7
636	Informe a situação do produto	d_filtro00333	3
637	Informe o tipo de pessoa	d_filtro00118	3
638	Informe o número do livro	d_filtro00326	2
639	Considerar produtos configurados como patrimônio	d_filtro00233	4
640	Informe a(s) cesta(s) ou branco para todas	d_filtro0561	2
641	Digite o período para a data de vencimento 	d_filtro0033	1
642	Digite o período para a data de movimento 	d_filtro0033	1
643	Digite o período para a data de pagamento 	d_filtro0033	1
644	Informe a(s) forma(s) de pagto ou branco p/ todas 	d_filtro0036	1
645	Digite a instituição (administradora)	d_filtro00115	1
646	Tipo da transação	d_filtro0060	1
647	Transportador ou branco para todos	d_filtro0013	1
648	Quantidade inicial de estoque	d_filtro00327	1
649	Informe empresa	d_filtro0031	1
650	Informe a Situação Tecnica	d_filtro_situacaotecnica	1
651	Informe o(s) motivo(s) de devolução	d_filtro_motivo_dev	1
652	Quantidade final de estoque	d_filtro00327	1
653	Tipo de alteração de preço	d_filtro00135	1
654	Digite a descrição parcial do item	d_filtro00115	1
655	Informe o tipo de categoria	d_filtro5000	1
656	Tipo de cálculo do PIS/COFINS	d_filtro00146	1
657	Informe a categoria do chamado	d_filtro00115	1
658	Informe a situação do chamado	d_filtro00115	1
659	Infome o nº da nota inicial	d_filtro00326	1
660	Informe o comprador ou branco para todos	d_filtro00430	3
661	Corredor (ou branco para todos)	d_filtro00200	2
662	Informe o tipo de movimento	d_filtro00446	2
663	Produto / Serviço	d_filtro_produto_servico	8
664	Informe a categoria do chamado	d_filtro00115	1
665	Informe a situação do chamado	d_filtro00115	1
666	Infome o nº da nota inicial	d_filtro00326	1
667	Informe a senha do vendedor   	d_filtro00115	8
668	Informe a codificação dos relatórios de invetário	d_filtro00215	5
669	Corredor (ou branco para todos)	d_filtro00200	2
670	Informe a bancada	d_filtro00211	4
671	Informe o tipo de movimento	d_filtro00446	2
672	Informe o % de divergencia	d_filtro00243	3
673	Informe o(s) COI de saída 1	d_filtro00120	6
674	Informe o(s) COI de saída 2	d_filtro00120	6
675	Informe a prioridade de entrega	d_filtro00289	2
676	Informe resa(s)	d_filtro0031	1
677	Data inici0	d_filtro00115	1
678	Data inicio	d_filtro00115	1
679	Informe a quantidade mínima de giro	d_filtro00327	4
680	Dt inicio	d_filtro00115	1
681	Informe a empresa 2	d_filtro0061	2
682	Informe o local de estoque 1	d_filtro00124	2
683	informe o local de estoque 2	d_filtro00124	2
684	Informe as divisões ou branco para todas	d_filtro00335	2
685	Produto / Serviço	d_filtro_produto_servico	8
686	Informe a(s) divisão(ões) ou branco para todos	d_filtro00561	5
687	Informe a empresa 1	d_filtro0061	4
688	Data inicial do 3º periodo	d_filtro00321	3
689	Data final do 3º periodo	d_filtro00322	2
690	Valor inicial	d_filtro00327	2
691	Valor final	d_filtro00327	2
692	Informe o ano	d_filtro00326	1
693	Informe o(s) motivo(s) de devolução	d_filtro00585	1
694	Informe a(s) seção(ões)	d_filtro00212	3
695	Situação dos Pedidos	d_filtro_sit_pedidos	2
696	Data movimentação inicial	d_filtro00321	2
697	Data movimentação final	d_filtro00321	2
698	Data de lançamento Inicial	d_filtro00321	4
699	Data de lançamento Final	d_filtro00322	2
700	Informe o grupo economico	d_filtro_grupo_economico	3
701	Apenas produtos Vendidos	d_filtro0028	5
702	Nª registro de entrada	d_filtro00289	1
703	Nª registro de saída	d_filtro00289	1
704	Situação de Conciliação de Cheques	d_filtro00581	1
705	Informe o n° do chque	d_filtro00329	2
706	Informe a quantidade inicial de venda (1° período)	d_filtro00326	3
707	Informe a quantidade inicial de venda (2° período)	d_filtro00326	3
708	Informe a quantidade inicial de estoque	d_filtro_qtdini	2
709	Informe a quantidade final de estoque	d_filtro_qtdfim	2
710	Informe o(s) divisor(es) ou branco para todos 	d_filtro00200	9
711	Calcular média diária dos últimos	d_filtro00289	1
712	Calcular excesso acima de	d_filtro00289	1
713	Informe a(s) forma(s) de pagto ou (bco ou 0)  p/ todas	d_filtro0036	3
714	Informe a situação da lista	d_filtro_situacao_lista	3
715	Preço Promoção:	d_filtro00207	4
716	Informe o nº de dias inicial	d_filtro00289	1
717	Informe o nº de dias final	d_filtro00289	1
718	Informe o nº de dias 	d_filtro00289	1
719	Situação	d_filtro00148	4
720	Margem 1	d_filtro00243	3
721	Margem 2	d_filtro00243	3
722	Margem 3	d_filtro00243	2
723	Margem 4	d_filtro00243	3
724	Margem 5	d_filtro00243	2
725	Coluna 1 a comparar	d_tipo_campo	2
726	Coluna 2 a comparar	d_tipo_campo	3
727	Tipo Movimentação	d_tipocoluna	2
728	Classificação(ões) contábil(eis) ou branco p/ todas	d_filtro_classificacao_contabil	5
729	Situação representação	d_situacao_representacao	5
730	% Alíquota interna	d_filtro00243	1
731	Quantidade de Fornecedores a Listar	d_filtro00323	3
732	Informe o nª da nota / mapa fiscal	d_filtro00326	3
733	Informe a pesquisa	d_filtro_pesquisa _crm	3
734	Informe a Pergunta	d_filtro_pergunta _crm 	4
735	Notas	d_filtro_pontuacao_notas	3
736	Informe o número do título	d_filtro00326	2
737	Informe a(s) empresaaaa(s)	d_filtro0031	1
738	Chave para pesquisa	d_filtro00115	3
739	Informe o tipo de movimento movimento(1) ou recebimentos (2)	d_filtro00326	4
740	Avisar vencimento	d_filtro0028	2
741	Informe o(s) número(s) da nota(s)	d_filtro00115	4
742	Informe o(s) número(s) da nota(s) I	d_filtro00115	7
743	Informe as Cidades entre virgula	d_filtro00115	4
744	Informe a Quantidade de Linhas	d_filtro00326	
745	Informe o Nº do Manifesto	d_filtro00326	1
746	Margem 2	d_filtro00131	4
747	Margem 3	d_filtro00131	3
748	Margem 4	d_filtro00131	4
749	Margem 5	d_filtro00131	3
750	O problema foi resolvido?	d_filtro00362	4
751	Situação Agendamento	d_filtro00433	3
752	Informe o tipo de baixa do produto a filtrar 	d_filtro0022	3
753	Informe a(s) bandeira(s)	d_filtro_bandeira	4
754	Informe o(s) número(s) da nota IV	d_filtro00115	4
755	Informe o responsável	d_filtro00153	2
756	Informe o E-mail ou branco para todos	d_filtro00115	
757	Margem 1	d_filtro00131	4
758	Considerar devoluções	d_filtro0028	3
759	Informe as versôes ou branco para todas	d_filtro00423	4
760	Informe as empresas para busca do estoque	d_filtro0031	3
761	Informa a margem final	d_filtro00327	2
762	Informe o CFOP ou Banco para Todos	d_filtro00326	2
763	Considerar Impostos de Compra/Venda	d_filtro00438	3
764	Informe o ponto de retirada	d_filtro00217	3
765	Tipo Pessoa	d_filtro00236	
766	Estado ou branco para todos 	d_filtro0012	
767	Cliente ou branco para todos 	d_filtro0013	
768	Data de cadastro 	d_filtro0014	
769	Vencimento do convênio 	d_filtro0015	
770	Convênio ou branco para todos 	d_filtro0016	
771	Data de aniversário 	d_filtro0017	
772	Situação do cliente 	d_filtro0018	
773	Selecione o tipo para o cliente / fornecedor 	d_filtro0019	
774	Somente produto que tem preço off-line 	d_filtro0021	
775	Tipo de produto a filtrar 	d_filtro0022	
776	Código do produto ou branco para todos 	d_filtro0023	
777	Produtos com preço 	d_filtro0024	
778	Modelo do produto 	d_filtro0025	
779	Localização 	d_filtro0026	
780	Periodo de faturamento / alteração  	d_filtro0027	
781	Somente itens pesáveis 	d_filtro0028	
782	Estoque com 	d_filtro0029	
783	Selecione status das duplidatas 	d_filtro0032	
784	Data de vencimento 	d_filtro0033	
785	Data de pagamento 	d_filtro0033	
786	Forma de pagamento ou branco para todas 	d_filtro0036	
787	Somente cliente a cobrar ? 	d_filtro0037	
788	Duplicatas com valor pendentes superior a 	d_filtro0038	
789	Cliente / fornecedor 	d_filtro0013	
790	Fornecedor 	d_filtro0013	
791	Selecione a origem da movimentação 	d_filtro0049	
792	Data de anivesário do cônjuge 	d_filtro00110	
793	Informe o código da atividade 	d_filtro00111	
794	Informe a cidade ou branco  para todas 	d_filtro00112	
795	Vendedor ou branco para todos 	d_filtro00113	
796	Região ou branco para todos 	d_filtro00114	
797	Subgrupo(s) ou branco para todos 	d_filtro00210	
798	Grupo(s) ou branco para todos 	d_filtro00211	
799	Seção ou branco para todos	d_filtro00212	
800	Informe o tipo de Banco ou branco para todos	d_filtro00581	1
801	Preços de atacado alterados depois de 	d_filtro00213	
802	Somente produto com cadeia de preço	d_filtro00214	
803	Data para auditoria de preços alterados 	d_filtro00215	
804	Data de início de promoção 	d_filtro0033	
805	Bairro ou branco para todos 	d_filtro00115	
806	Cidade ou branco para todos 	d_filtro00116	
807	COI ou branco para todos 	d_filtro00119	
808	Local de estoque ou branco para todos 	d_filtro00124	
809	Vendedor ou branco para todos 	d_filtro00121	
810	Estado civil	d_filtro00122	
811	CEP ou branco para todos	d_filtro00125	
812	Cliente / fornecedor ou branco para todos	d_filtro0013	
813	Endereço ou branco para todos	d_filtro00127	
814	Tipo de residência	d_filtro00128	
815	Data inicial da promoção	d_filtro00219	
816	Informe o nº do pré-pedido ou branco para todos	d_filtro00326	3
817	Situação do Clientes	d_filtro_situacao_clientes	3
818	Informe a célula (fila) de atendimento ou branco para todas	d_filtro00115	2
819	Data final da promoção	d_filtro00219	
820	Subproduto 	d_filtro0023	
821	Data para posição	d_filtro00321	
822	Seção ou 0 (zero) para todos	d_filtro00212	
823	Item mestre ou branco para todos	d_filtro0023	
824	Número de dias 	d_filtro00323	
825	Número da nota ou branco para todos	d_filtro00324	
826	Usuário 	d_filtro00430	
827	Produto ou branco para todos	d_filtro0023	
828	Data de alteração dos preços	d_filtro00235	
829	Número do cupom ou branco para todos	d_filtro00325	
830	Nº do Caixa	d_filtro00288	
831	Data de cancelamento	d_filtro0017	
832	Data de aniversário final	d_filtro00321	
833	Pendentes,Liquidadas ou Ambas	d_filtro00130	
834	Número do orçamento	d_filtro00319	
835	Qtd Estoque	d_filtro00327	
836	Fabricante / Marca	d_filtro00238	
837	Informe o Kit 	d_filtro002401	
838	Informe o nº de pontos(por R$1,00 vendido)	d_filtro00131	
839	Tipo Situação Tributária 	d_filtro00240	
840	Atraso acima de X dias 	d_filtro00323	
841	Número do Pedido ou branco para todos	d_filtro00326	
842	Número da Cotação	d_filtro00323	
843	Informe o código da separação	d_filtro00328	2
844	Informe o(s) número(s) da nota(s) II	d_filtro00115	3
845	Informe os clientes	d_filtro0031	2
846	Somente departamentos comerciais	d_filtro0028	8
847	Informe o Tipo de Cadastro de Vendedor	d_filtro00115	2
848	Tipo Auxílio	d_filtro_auxilio	3
849	Informe o cobrador ou branco para todos	d_filtro00126	5
850	Forma(s) de pagto ou branco  p/ todas	d_filtro0036	5
851	Status nota	d_filtro0564	2
852	Informe o Centro de Resultado	d_filtro00586	2
853	Tipo de situação cst	d_exigeconfiguracao_piscofins	2
854	Nível 2	d_filtro00327	1
855	Nível 3	d_filtro00327	1
856	Nível 1	d_filtro00327	1
857	Exibe t?tulos agrupados	d_filtro_agrupados	2
858	Informe o(s) n?mero(s) da nota(s) iii	d_filtro00115	4
859	Data autoriza??o inicial	d_filtro00321	2
860	Data autoriza??o final	d_filtro00322	3
861	Informe a quantidade m?nima de giro	d_filtro00327	4
862	Informe o n? da autoriza??o ou branco para todas	d_filtro00326	1
863	Informe o tipo da entrega(1-Loja, 2-Central)	d_filtro00326	2
864	N?vel 1	d_filtro00327	1
865	Somente contas de Mutuo	d_filtro00233	2
866	Bonifica??o com % pago inferior a	d_filtro00131	4
867	Informe a série ou branco para todas	d_filtro00411	7
868	Data final de promoção inicial	d_filtro00321	2
869	Data final de promoção final	d_filtro00322	2
870	Nível 4	d_filtro00327	1
871	Somente produtos sem produção	d_filtro0028	1
872	Informe o nº do mês	d_filtro00326	1
873	Mostrar somente produtos com diferença de custo	d_filtro00233	1
874	Bonificação com % pago inferior a	d_filtro00131	4
875	Ativo / inativo para venda	d_filtro00139	1
876	Informe a(s) Cta(s) Contabil(s) ou branco p/ todos	d_filtro00439	2
877	Informe a quantidade máxima	d_filtro00327	1
878	Informe a empresa CD	d_filtro0031	1
879	Informe a série	d_filtro00326	2
880	Informe o tipo do cadastro	d_filtro0019	2
881	Informe o tipo da nota fiscal	d_filtro00413	2
882	Data início faturamento	d_filtro00321	4
883	Data da validade reserva	d_filtro00322	2
884	Informe a(s) empresa(s) Saldo de Estoque	d_filtro0031	1
885	Exceção de Clientes 	d_filtro0013	1
886	Exceção de Clientes 2	d_filtro0013	1
887	Tipo vendas(1) recebimentos (2)	d_filtro00326	5
888	Informe a release	d_filtro00422	
889	Informe a data da release	d_filtro00322	
890	Informe um corredor ou branco para todos	d_filtro00115	4
891	Infome o local de entrega	d_filtro00326	1
892	Somente adiantamentos	d_filtro00191	1
893	Informe o(s) centro(s) de resultado	d_filtro00586	4
894	Tipo cst saída	d_cst_saida_filtro	4
895	NOTA 1	d_filtro00115	1
896	NOTA 2	d_filtro00115	1
897	NOTA 3	d_filtro00115	1
898	NOTA 4	d_filtro00115	1
899	NOTA 5	d_filtro00115	1
900	Informe a(s) classificação(ões) contábil(eis) ou branco para todas	d_filtro00440	2
901	Informe o nº da cotação	d_filtro00326	1
902	Informe a quantidade máxima de estoque	d_filtro_quant_minima_estoque	3
903	Informe a Bandeira	d_filtro0066	1
904	Informe o tipo da promoção	d_filtro00115	
905	Quantidade de estoque final	d_filtro00326	4
906	Quantidade de estoque inicial	d_filtro00326	3
907	Forma(s) de pagamento	d_filtro0036	1
908	Tipo Movimento nota/cupom/ambas	d_filtro0566	1
909	Pendentes, liquidadas ou ambas	d_filtro00146	1
910	Informe o código interno do fornecedor	d_filtro00115	4
911	Informe o código interno do fornecedor	d_filtro0561	5
912	Informe a situação do titulo	d_filtro0565	2
913	Infome o local de entrega ou branco para todos	d_filtro00217	1
914	(Sim)Para todos (Não)Somente sem liberação	d_filtro00233	1
915	(Sim)Para todos (Não)Somente com erros	d_filtro00233	1
916	Informe a(s) cta(s) contábil(eis) ou branco p/ todos	d_filtro00439	5
917	Pendentes,Aprovados,liquidadas ou ambas	d_filtro00130	1
918	Informe o nº da planilha de origem	d_filtro00326	2
919	Pendentes, liquidadas ou ambas TESTE	d_filtro00130	1
920	Pendentes, testados,liquidadas ou ambas	d_filtro00130	1
921	Pendentes,teste2,liquidadas ou ambas	d_filtro00130	1
922	Filtro teste 1	d_filtro00321	2
923	Pendentes,teste3,liquidadas ou ambas	d_filtro00130	1
924	Pendentes,teste4,liquidadas ou ambas	d_filtro00130	1
925	Pendentes, tesluan,liquidadas ou ambas	d_filtro00130	1
926	Pendentes,testeLuan,liquidadas ou ambas	d_filtro00130	1
927	Motivo Cancelamento	d_filtro0050012	1
928	Informe o % de variação	d_filtro00131	2
929	Tipo cst entrada	d_cst_entrada_filtro	2
930	Dia de vencimento cartão 	d_filtro00323	4
931	Informe a descrição para cabeçalho	d_filtro000115	4
932	Informe a(s) forma(s) de pagto ou bco p/ todas	d_filtro0036	4
933	Informe a série ou branco para todas	d_filtro00127	5
934	 Informe o fornecedor	d_filtro0061	1
935	Informe o n° do fornecedor	d_filtro0013	4
936	Data Inicial do Vencimento	d_filtro0021	1
937	Data Final do Vencimento	d_filtro0022	1
938	Chamado externo pago	d_filtro0028	3
939	Situação do patrimônio ou branco para todas	d_filtro00291	11
940	Informe o nº do caixa ou zero	d_filtro00326	1
941	 Informe o fornecedor	d_filtro0013	1
942	Bloq. impressão de faturas de clientes inadimplentes	d_filtro00233	1
943	Informe o valor mínimo	d_filtro00327	4
944	Informe o valor mínimo	d_filtro0038	4
945	Informe o valor mínimo	d_filtro00131	4
946	Informe o nosso número ou branco para todos 	d_filtro00326	1
947	Data movimento inicial	d_filtro00322	1
948	Listar as Contas Analiticas?	d_filtro00257	3
949	Data inicial TESTE	d_filtro00321	1
950	Data final TESTE	d_filtro00322	1
951	Exceção de Clientes 	d_filtro00115	1
952	Exceção de Clientes 2	d_filtro00115	1
953	Data de movimento inicial	d_filtro00322	1
954	Informe o nosso número ou branco para todos 	d_filtro00115	1
955	Informe as Contas separando por vírgulas	d_filtro00115	1
956	Informe o(s) Centro(s) de Resultado ou branco para todos	d_filtro00586	2
957	Informe o Número RD	d_filtro00326	1
958	Informe o Albarán	d_filtro00326	1
959	Informe o Albáran	d_filtro00326	1
960	Informe MATERIAL ou SUPERMERCADO	d_filtro00115	4
961	Informe o Tipo Natureza	d_filtro0060	1
962	Formas de pagamento Ã  vista	d_filtro00257	3
963	Formas de pagamento   vista	d_filtro00257	3
964	Informe a alIquota	d_filtro00229	1
965	Informe a alIquota de entrada	d_filtro00229	1
966	Informe o(s) subgrupo(s) 	d_filtro00210	2
967	Informe a(s) divisão(ões) 	d_filtro00213	5
968	Informe a marca/fabricante	d_filtro_marcafabricante	1
969	Informe o(s) usuário(s) solicitantes ou branco para todos	d_filtro00430	5
970	Usuário(s) de liberação ou branco para todos	d_filtro00700	4
971	Exibe t¡tulos agrupados	d_filtro_agrupados	2
972	Informe o(s) n£mero(s) da nota(s) iii	d_filtro00115	4
973	Data autoriza‡Æo inicial	d_filtro00321	2
974	Data autoriza‡Æo final	d_filtro00322	3
975	Somente produtos sem produ‡Æo	d_filtro0028	1
976	Informe o n§ do mˆs	d_filtro00326	1
977	Informe o valor	d_filtro00131	1
978	Mostar Apenas os Produtos a Serem Comprados?	d_filtro00233	1
979	Produto a ser Ignorado	d_filtro0023	1
980	Informe o código do Balanço	d_filtro00115	2
981	Informe o Codigo de Barras ou Codigo Interno	d_filtro00215	5
982	Número de Páginas do Livro	d_filtro00289	1
983	Prateleira (ou branco para todas)	d_filtro00	
984	Informe o valor	d_filtro00327	1
985	Informe a empresa SOLICITANTE	d_filtro0061	2
986	Informe o local de estoque FORNECEDOR	d_filtro00124	3
987	Informe o local de estoque SOLICITANTE	d_filtro00124	2
988	Informe a empresa FORNECEDORA	d_filtro0031	1
989	Informe o tipo de movimento	d_filtro00147	1
990	Isenção PIS/COFINS	d_filtro00293	5
991	movimento Impresso	d_filtro00322	1
992	Data de movimento inicial TESTE	d_filtro00321	1
993	Data de movimento final TESTE	d_filtro00322	1
994	Empresa destino	d_filtro0061	3
995	Informe a data de levantamento do estoque	d_filtro_data_levantamento_es	
996	Tipo de cliente ou branco para todos	d_filtro_tipocliente	1
997	Informa a letra do Cliente	d_filtro00115	1
998	Informe o Local de Entrega	d_filtro00326	1
999	Informe o Código da Bandeira	d_filtro00411	1
1000	Empresa origem	d_filtro0061	2
1001	Informe a(s) editora(s) ou deixe em branco para todas	d_filtro00211	1
1002	Apresenta Produtos com Reserva	d_filtro000119	1
1003	Usuário(s) solicitantes ou branco para todos	d_filtro00430	4
1004	Mostrar ECFs? (S=Sim/N=Não/T=Todas as Vendas)	d_filtro00115	2
1005	Informe o % de Impressão	d_filtro00326	4
1006	informe o socio ou branco pra todos	d_filtro0031	2
1007	Tipo	d_filtro00115	2
1008	Informe a localização do patrimônio	d_filtro0070	2
1009	Listar provisoes	d_filtro0028	4
1010	Informe o cliente ou branco para todos 	d_filtro0072	1
1011	Informe o cliente / fornecedor ou branco para todos	d_filtro0072	1
1012	Informe o cliente	d_filtro0072	3
1013	Empresa(s) destino ou branco para todos	d_filtro00449	4
1014	Situação Lote Ativo, Inativo ou Ambos	d_filtro0010	2
1015	Informe o dia do vencimento do convenio	d_filtro00326	2
1016	Informe o cÃ³digo inicial do cliente	d_filtro00326	1
1017	Informe o convÃªnio ou branco para todos 	d_filtro0016	1
1018	Informe a origem de movimento contÃ¡bil	d_filtro00118	1
1019	Informe a situaÃ§Ã£o do crÃ©dito do cliente 	d_filtro0018	1
1020	Informe o cÃ³digo final do cliente	d_filtro00326	1
1021	Informe o local de estoque que serÃ¡ abastecido	d_filtro00124	1
1022	Informe a promoÃ§Ã£o	d_filtro00142	1
1023	Imprimir somente itens pesÃ¡veis 	d_filtro0028	1
1024	Informe o nº do balanÃ§o ou zero para todos	d_filtro00326	1
1025	Informe o perÃ­odo para a data de vencimento 	d_filtro0033	2
1026	Informe o perÃ­odo para a data de movimento 	d_filtro0033	2
1027	Informe o perÃ­odo para a data de pagamento 	d_filtro0033	2
1028	Informe a versÃ£o	d_filtro00423	3
1029	Informe a localizaÃ§Ã£o ou branco para todas	d_filtro_depart	1
1030	Informe a regiÃ£o ou branco para todos 	d_filtro00114	1
1031	Informe a(s) seÃ§Ã£o(Ãµes) ou branco para todos 	d_filtro00212	1
1032	Informe a categoria da operaÃ§Ã£o interna	d_filtro_categoriacoi	4
1033	Informe a sÃ©rie ou branco para todas	d_filtro00115	6
1034	Informe o dia do aniversÃ¡rio	d_filtro0032	3
1035	Informe o grupo econômico xxx	d_filtro_grupo_economico	4
1036	Fornecedor da última nota?	d_filtro0028	1
1037	Informe o mÃªs do aniversÃ¡rio	d_filtro0042	3
1038	Informe a alÃ­quota 	d_filtro00229	1
1039	Informe o n° da conta bancÃ¡ria	d_filtro00411	5
1040	Informe o cÃ³digo suframa	d_filtro00115	4
1041	Informe o endereÃ§o ou branco para todos	d_filtro00115	1
1042	Informe o tipo de residÃªncia	d_filtro00128	1
1043	Informe o nº da prÃ©-venda	d_filtro00115	4
1044	Data para posiÃ§Ã£o	d_filtro00322	1
1045	Informe a situaÃ§Ã£o do pedido	d_filtro00432	3
1046	Informe o usuÃ¡rio ou branco para todos	d_filtro00430	1
1047	Informe a situaÃ§Ã£o do agendamento	d_filtro00433	4
1048	PerÃ­odo por atraso	d_filtro00150	6
1049	Informe o(s) usuÃ¡rio(s) ou branco para todos	d_filtro00430	4
1050	Data de aniversÃ¡rio inicial	d_filtro00321	1
1051	Data de aniversÃ¡rio final	d_filtro00322	1
1052	Informe o nº do orÃ§amento ou branco para todos	d_filtro00326	1
1053	Informe a conta bancÃ¡ria	d_filtro00132	1
1054	PerÃ­odo de data de nascimento	d_filtro00431	1
1055	Informe a instituiÃ§Ã£o (administradora)	d_filtro00115	2
1056	Informe o tipo da transaÃ§Ã£o	d_filtro0060	2
1057	Informe a conta contÃ¡bil	d_filtro00133	1
1058	Informe o tipo situaÃ§Ã£o tributÃ¡ria 	d_filtro00240	1
1059	Informe a situaÃ§Ã£o atual do cheque	d_filtro00241	1
1060	Informe o nº da pÃ¡gina inicial	d_filtro00289	1
1061	Data previsÃ£o de entrega inicial	d_filtro00321	1
1062	Data previsÃ£o de entrega final	d_filtro00322	1
1063	Data de emissÃ£o inicial	d_filtro00321	1
1064	Data de emissÃ£o final	d_filtro00322	1
1065	Selecione o mÃ³dulo	d_filtro0050	1
1066	Data inicial do Ãºltimo log 	d_filtro00321	1
1067	Data final do Ãºltimo log	d_filtro00322	1
1068	Informe o funcionÃ¡rio ou branco para todos	d_filtro0013	1
1069	Informe o tipo de alteraÃ§Ã£o de preÃ§o	d_filtro00135	2
1070	PreÃ§os zerados e/ou nÃ£o	d_filtro00136	1
1071	PreÃ§os em promoÃ§Ã£o e/ou nÃ£o	d_filtro00137	1
1072	Informe a situaÃ§Ã£o de vendas futuras	d_filtro00138	1
1073	SituaÃ§Ã£o do cadastro do produto ativo/inativo	d_filtro00139	1
1074	Data/Hora previsÃ£o de entrega inicial	d_filtro00140	1
1075	Data/Hora previsÃ£o de entrega final	d_filtro00141	1
1076	SituaÃ§Ã£o do cnpj/cpf dos clientes	d_filtro00142	1
1077	Data de alteraÃ§Ã£o inicial	d_filtro00321	1
1078	Data de alteraÃ§Ã£o final	d_filtro00322	1
1079	Informe a descriÃ§Ã£o parcial do item	d_filtro00115	2
1080	Data de balanÃ§o	d_filtro00322	1
1081	SituaÃ§Ã£o de pis/cofins	d_filtro00143	1
1082	Informe o tipo do preÃ§o	d_filtro00145	1
1083	Data inicial da primeira faixa de horÃ¡rio	d_filtro00321	1
1084	Data final da primeira faixa de horÃ¡rio	d_filtro00322	1
1085	Data inicial da segunda faixa de horÃ¡rio	d_filtro00321	1
1086	Data final da segunda faixa de horÃ¡rio	d_filtro00322	1
1087	Informe o tipo de cÃ¡lculo do PIS/COFINS	d_filtro00146	2
1088	Informe o tipo de emissÃ£o	d_filtro00147	1
1089	Data de promoÃ§Ã£o inicial	d_filtro00321	1
1090	Data de promoÃ§Ã£o final	d_filtro00322	1
1091	SituaÃ§Ã£o do cadastro do cliente ativo/inativo	d_filtro00139	1
1092	Informe o % de bonificaÃ§Ã£o	d_filtro00131	1
1093	Informe a gerÃªncia ou branco para todos	d_filtro0013	1
1094	Informe o responsÃ¡vel ou branco para todos	d_filtro0013	1
1095	Informe dias do Ãºltimo movimento maior que	d_filtro00289	1
1096	Informe parte da descriÃ§Ã£o da categoria do chamado	d_filtro00115	2
1097	Informe parte da descriÃ§Ã£o da situaÃ§Ã£o do chamado	d_filtro00115	2
1098	Informe o mÃ³dulo	d_filtro0050	1
1099	Informe o tipo da situaÃ§Ã£o 	d_filtro00250	1
1100	Informe a situaÃ§Ã£o dos chamados pendentes/baixados	d_filtro00148	1
1101	Data de balanÃ§o inicial	d_filtro00321	1
1102	Data de balanÃ§o final	d_filtro00322	1
1103	Informe o patrimÃ´nio	d_filtro0065	1
1104	Informe o nº da cotaÃ§Ã£o	d_filtro00326	1
1105	Informe o valor mÃ­nimo de ir	d_filtro00131	4
1106	Porcentagem p/ impressÃ£o	d_filtro00131	3
1107	SituaÃ§Ã£o da duplicata	d_filtro0051	3
1108	Data de cobranÃ§a inicial	d_filtro00321	2
1109	Data de cobranÃ§a final	d_filtro00322	2
1110	Informe a cadeia de preÃ§os	d_filtro_cadeiapreco	3
1111	ObservaÃ§Ã£o de retirada do produto	d_filtro_obsproduto	3
1112	Informe a codificaÃ§Ã£o dos relatÃ³rios de invetÃ¡rio	d_filtro00215	5
1113	Informe o perÃ­odo para a data de promoÃ§Ã£o	d_filtro0033	4
1114	Data fim de promoÃ§Ã£o inicial	d_filtro00321	4
1115	Data fim de promoÃ§Ã£o final	d_filtro00322	5
1116	Informe a situaÃ§Ã£o de nota de transferÃªncia	d_filtro_situacao_nota	2
1117	Informe o nÃºmero da nota	d_filtro00326	2
1118	Informe a situaÃ§Ã£o da transaÃ§Ã£o	d_filtro00228	3
1119	Informe o c³digo inicial do cliente	d_filtro00326	1
1120	Informe o orÃ§amento	d_filtro00326	2
1121	Informe o(s) usuÃ¡rio(s)	d_filtro00430	2
1122	Informe o % para comissÃ£o	d_filtro00131	4
1123	Informe a situaÃ§Ã£o do patrimÃ´nio	d_filtro240	10
1124	Custo para a valorizaÃ§Ã£o da diferenÃ§a	d_filtro0241	2
1125	Informe o nÃºmero de dias para sugestÃ£o de compras	d_filtro00289	4
1126	Informe o % de deflaÃ§Ã£o	d_filtro00243	3
1127	Somente produtos com sugestÃ£o de compras	d_filtro0028	5
1128	Informe o Ã­ndice de correÃ§Ã£o	d_filtro00255	3
1129	Percentual de acrÃ©scimo a ser aplicado	d_filtro00256	2
1130	SituaÃ§Ã£o	d_filtro00148	4
1131	Tipo de cÃ¡lculo do pis/cofins	d_filtro00201	2
1132	GÃ´ndola (ou branco para todas)	d_filtro00200	3
1133	Informe o cÃ³digo da famÃ­lia	d_filtro00210	2
1134	Data inicial perÃ­odo anterior	d_filtro00321	3
1135	Data final perÃ­odo anterior	d_filtro00322	3
1136	Informe a famÃ­lia	d_filtro00210	7
1137	Informe a(s) divisÃ£o(Ãµes) ou branco para todos	d_filtro00561	5
1138	Informe o mÃªs	d_filtro_mes	3
1139	Informe a descriÃ§Ã£o do cabeÃ§alho 	d_filtro00115	4
1140	Informe o grupo econÃ´mico	d_filtro_grupo_economico	4
1141	Informe o(s) grupos de usuÃ¡rio(s) ou branco todos 	d_filtro00430	3
1142	Informe a alÃ­quota de entrada	d_filtro00229	4
1143	Informe a alÃ­quota de saÃ­da	d_filtro00229	6
1144	Informe as divisÃµes ou branco para todas	d_filtro00335	2
1145	Informe a quantidade inicial de venda ou branco todas (1° perÃ­odo)	d_filtro00326	2
1146	Informe a quantidade inicial de venda ou branco todas (2° perÃ­odo)	d_filtro00326	2
1147	SituaÃ§Ã£o da ordem de serviÃ§o	d_filtro00151	2
1148	Informe o nº da ordem de serviÃ§o	d_filtro00152	4
1149	Informe o responsÃ¡vel	d_filtro00430	3
1150	Informe a localizaÃ§Ã£o do patrimonio	d_filtro00291	2
1151	Informe a quantidade mÃ­nima de estoque	d_filtro_quant_minima_estoque	3
1152	Informe o status do mÃ³dulo	d_filtro0068	2
1153	Informe a situaÃ§Ã£o atual do cheque	d_filtro_situacao_cheque	2
1154	Informe o nÃºmero da encomenda	d_filtro00446	3
1155	Produtos em promoÃ§Ã£o:	d_filtro00207	3
1156	Informe o motivo da devoluÃ§Ã£o	d_filtro00115	2
1157	Informe o nº do VÃ£o ou branco para todos	d_filtro00326	4
1158	Informe a Ã¡rea	d_filtro00447	2
1159	Informe a bonificaÃ§Ã£o	d_filtro00326	2
1160	Informe a(s) forma(s) de pagto que nÃ£o deve listar	d_filtro0036	3
1161	Somente Produtos com PrÃ©-Pedido(s) Pendente(s)	d_filtro_produto_pendente_prepedido	2
1162	Status da negociaÃ§Ã£o	d_filtro00563	3
1163	Tipo do preÃ§o	d_filtro00564	2
1164	Prazo da negociaÃ§Ã£o	d_filtro00565	2
1165	Informe a sÃ©rie	d_filtro00566	2
1166	Informe o nº do prÃ©-pedido ou branco para todos	d_filtro_nro_prepedido	2
1167	SituaÃ§Ã£o do(s) PrÃ©-Pedido(s)	d_filtro_situacao_prepedido	2
1168	Informe o nº da autorizaÃ§Ã£o	d_filtro00229	2
1169	Informe a(s) Cta(s) ContÃ¡bil(s) ou branco p/ todos	d_filtro00439	5
1170	Tipo de PreÃ§o PrÃ©-Pedido	d_filtro_tipo_preco_prepedido	2
1171	SituaÃ§Ã£o do Clientes	d_filtro0018	4
1172	Tipo da Nota de TransferÃªncia	d_filtro00356	2
1173	AvaliaÃ§Ã£o do atendente	d_filtro00361	3
1174	AvaliaÃ§Ã£o da ferramenta de atendimento	d_filtro00361	2
1175	Informe a cÃ©lula de atendimento ou branco p/ todas	d_filtro00115	4
1176	Informe o(s) COI de saÃ­da 1	d_filtro00120	6
1177	Informe o(s) COI de saÃ­da 2	d_filtro00120	6
1178	Tipo SolicitaÃ§Ã£o	d_filtro00155	2
1179	Informe o convªnio ou branco para todos 	d_filtro0016	1
1180	1º data para posiÃ§Ã£o de estoque	d_filtro00322	2
1181	2º data para posiÃ§Ã£o de estoque	d_filtro00322	2
1182	SituaÃ§Ã£o pis/cofins	d_filtro00568	2
1183	SituaÃ§Ã£o tributÃ¡ria	d_filtro00569	2
1184	Data de produÃ§Ã£o inicial	d_filtro00321	2
1185	Data de produÃ§Ã£o final	d_filtro00322	3
1186	Informe o % de variaÃ§Ã£o de custo inicial	d_filtro00131	4
1187	Informe o % de variaÃ§Ã£o de custo final	d_filtro00131	2
1188	Digite a observaÃ§Ã£o	d_filtro00571	2
1189	Quantidade de produtos por divisÃ£o a listar	d_filtro00326	4
1190	Informe a empresa de produÃ§Ã£o	d_filtro0031	6
1191	Informe o nº do caixa que nÃ£o deve mostrar 	d_filtro00326	4
1192	Listar somente produtos com divergÃªncia	d_filtro0028	3
1193	Mostra tÃ­tulos da tesouraria	d_filtro00438	3
1194	SituaÃ§Ã£o do pedido	d_filtro00410	4
1195	SituaÃ§Ã£o da bonifiacaÃ§Ã£o	d_filtro0562	3
1196	Tipo da BonificaÃ§Ã£o	d_filtro0563	3
1197	Informe a rede de negÃ³cios	d_filtro_rede_negocio	2
1198	Informe a situaÃ§Ã£o da entrega	d_filtro_situacaologistica	3
1199	Informe a conta contÃ¡bil (crÃ©dito) de troco	d_filtro00133	4
1200	Informe a conta contÃ¡bil (crÃ©dito)  de contra-vale	d_filtro00133	4
1201	ClassificaÃ§Ã£o(Ãµes) contÃ¡bil(eis) ou branco p/ todas	d_filtro00440	4
1202	Informa o nÃºmero da remessa	d_filtro00566	2
1203	Informe a situaÃ§Ã£o de cobranÃ§a	d_filtro_situacao_cobranca	3
1204	Informe o cÃ³digo da separaÃ§Ã£o	d_filtro00326	3
1205	Informe o histÃ³rico contÃ¡bil	d_filtro_historico_contabil	3
1206	Informe a origem de movimento cont¡bil	d_filtro00118	1
1207	Informe a situa§£o do cr©dito do cliente 	d_filtro0018	1
1208	Informe o nÃºmero da autorizaÃ§Ã£o	d_filtro00326	2
1209	Somente serviÃ§os	d_filtro_flagIss	3
1210	Tipo classificaÃ§Ã£o	d_filtro_classificacao_ctba	2
1211	Informe a situaÃ§Ã£o atual dos cheques	d_filtro_situacao_atual_cheque	3
1212	Informe o(s) orÃ§amento(s)	d_filtro00452	7
1213	Informe a situaÃ§Ã£o das vendas futuras 	d_filtro00453	4
1214	SituaÃ§Ã£o notas	d_filtro_notas_servico_canceladas	2
1215	Tipo relatÃ³rio	d_filtro00457	3
1216	Produtos com sugestÃ£o de compras	d_filtro00576	2
1217	Somente notas com divergÃªncia	d_filtro0028	4
1218	VersÃ£o	d_filtro00566	2
1219	% AlÃ­quota interna	d_filtro_aliquota_interna	4
1220	Informe o veÃ­culo	d_filtro_veiculo	2
1221	Nª do registro de saÃ­da	d_filtro00289	2
1222	SituaÃ§Ã£o do Estoque	d_filtro00580	2
1223	SituaÃ§Ã£o	d_filtro00139	1
1224	Dias para cÃ¡lculo da mÃ©dia diÃ¡ria de venda	d_filtro00289	2
1225	Dias para cÃ¡lculo de excesso	d_filtro00289	2
1226	Dias para cÃ¡lculo de faltas	d_filtro00289	2
1227	Considerar acrÃ©scimos no cÃ¡lculo da comissÃ£o	d_filtro0028	1
1228	Informe o nº da PrÃ©-Carga	d_filtro00326	2
1229	Subtrair as devoluÃ§Ãµes	d_filtro00233	2
1230	SituaÃ§Ã£o cheques conciliados	d_filtro00581	2
1231	Selecione o grupo de patrimÃ´nios	d_filtro00491	2
1232	Informe o tipo do patrimÃ´nio	d_filtro00584	3
1233	Informe o nÃºmero do livro	d_filtro00326	2
1234	Considerar produtos configurados como patrimÃ´nio	d_filtro00233	4
1235	Digite o perÃ­odo para a data de vencimento 	d_filtro0033	1
1236	Informe o(s) usuÃ¡rio(s) que nÃ£o deve mostrar	d_filtro00430	2
1237	SituaÃ§Ã£o do crÃ©dito do cliente 	d_filtro0018	1
1238	SituaÃ§Ã£o atual do cheque	d_filtro00241	1
1239	SituaÃ§Ã£o de vendas futuras	d_filtro00138	1
1240	Informe o COI de SaÃ­da 1	d_filtro00119	4
1241	Informe o COI de SaÃ­da 2	d_filtro00119	4
1242	Informe o tipo de promoÃ§Ã£o	d_filtro00142	
1243	Informe a localizaÃ§Ã£o do patrimonio	d_filtro0070	8
1244	Inform a situaÃ§Ã£o do produto	d_filtro00333	2
1245	Informe a data inicial do primeiro perÃ­odo	d_filtro00321	2
1246	Informe a data final do primeiro perÃ­odo	d_filtro00322	2
1247	Informe a data inicial do segundo perÃ­odo	d_filtro00321	2
1248	Informe a data final do segundo perÃ­odo	d_filtro00322	2
1249	Informe a(s) divisÃ£o(Ãµes) ou branco para todas	d_filtro00213	4
1250	SituaÃ§Ã£o do cadastro de produto novo/reativado	d_filtro00334	1
1251	Digite o perÃ­odo para a data de movimento 	d_filtro0033	1
1252	Digite o perÃ­odo para a data de pagamento 	d_filtro0033	1
1253	Digite a instituiÃ§Ã£o (administradora)	d_filtro00115	1
1254	Tipo da transaÃ§Ã£o	d_filtro0060	1
1255	Tipo de alteraÃ§Ã£o de preÃ§o	d_filtro00135	1
1256	Digite a descriÃ§Ã£o parcial do item	d_filtro00115	1
1257	Tipo de cÃ¡lculo do pis/cofins	d_filtro00146	
1258	Informe a situaÃ§Ã£o do chamado	d_filtro00115	1
1259	Selecione o grupo de patrimÃ´nios	d_filtro00581	1
1260	Informe a situaÃ§Ã£o do patrimonio	d_filtro00290	4
1261	Informe a situaÃ§Ã£o do produto	d_filtro00333	3
1262	Produto / ServiÃ§o	d_filtro_produto_servico	8
1263	Informe a(s) divisÃ£o(Ãµes) ou branco para todos	d_filtro00211	2
1264	Informe a quantidade inicial de venda (1° perÃ­odo)	d_filtro00326	3
1265	Informe a quantidade inicial de venda (2° perÃ­odo)	d_filtro00326	3
1266	Formas de pagamento Ã  vista	d_filtro00257	3
1267	SituaÃ§Ã£o do cliente no cartÃ£o prÃ³prio ativo/inativo	d_filtro00139	4
1268	Tipo de cartÃ£o (dÃ©bito/crÃ©dito/ambos)	d_filtro0060	2
1269	Data de digitaÃ§Ã£o inicial	d_filtro00321	2
1270	Data de digitaÃ§Ã£o final	d_filtro00322	2
1271	Data inicial de aquisiÃ§Ã£o	d_filtro00321	1
1272	Data final de aquisiÃ§Ã£o	d_filtro00322	1
1273	Informe o(s) motivo(s) de devoluÃ§Ã£o	d_filtro00585	1
1274	Informe a situaÃ§Ã£o da lista	d_filtro_situacao_lista	3
1275	PreÃ§o PromoÃ§Ã£o:	d_filtro00207	4
1276	Informe a localizaÃ§Ã£o do patrimÃ´nio	d_filtro_localizacaopatrimonio	5
1277	Informe a orientaÃ§Ã£o do papel	d_filtro00252	2
1278	Informe a(s) seÃ§Ã£o(Ãµes)	d_filtro00212	3
1279	Data movimentaÃ§Ã£o inicial	d_filtro00321	2
1280	Data movimentaÃ§Ã£o final	d_filtro00321	2
1281	Data de lanÃ§amento Inicial	d_filtro00321	4
1282	Data de lanÃ§amento Final	d_filtro00322	2
1283	Informe o nÃºmero do tÃ­tulo	d_filtro00326	2
1284	Informe a codificaÃ§Ã£o dos relatÃ³rios de inventÃ¡rio	d_filtro00215	6
1285	Informe a Data para auditoria de preÃ§os alterados 	d_filtro00215	
1286	PreÃ§os alterados depois de  	d_filtro00216	
1287	PreÃ§os nÃ£o alterados desde	d_filtro00217	
1288	Informe o perÃ­odo para data de inÃ­cio de promoÃ§Ã£o 	d_filtro0033	
1289	Produtos exportÃ¡veis para frente de caixa 	d_filtro00230	
1290	Informe a data final da promoÃ§Ã£o	d_filtro00219	
1291	Informe a seÃ§Ã£o ou 0 (zero) para todos	d_filtro00212	
1292	DigÃ­te o periodo para a data de pagamento	d_filtro0017	
1293	Informe a SituaÃ§Ã£o Tecnica	d_filtro_situacaotecnica	1
1294	Informe o(s) motivo(s) de devoluÃ§Ã£o	d_filtro_motivo_dev	1
1295	Informe o mÃªs de nascimento	d_filtro00401	
1296	Informe uma seÃ§Ã£o	d_filtro00212	
1297	SeÃ§Ã£o ou 0 para todas 	d_filtro00234	
1298	Informe a senha do usuÃ¡rio do vendedor	d_filtro_senha	10
1299	Informe a quantidade mÃ­nima de giro	d_filtro00327	4
1300	Calcular mÃ©dia diÃ¡ria dos Ãºltimos	d_filtro00289	1
1301	Nª registro de saÃ­da	d_filtro00289	1
1302	SituaÃ§Ã£o de ConciliaÃ§Ã£o de Cheques	d_filtro00581	1
1303	Informe o(s) nÃºmero(s) da nota(s)	d_filtro00115	4
1304	Informe o(s) nÃºmero(s) da nota(s) I	d_filtro00115	7
1305	Informe o(s) nÃºmero(s) da nota IV	d_filtro00115	4
1306	Informe o responsÃ¡vel	d_filtro00153	2
1307	SituaÃ§Ã£o Agendamento	d_filtro00433	3
1308	Considerar devoluÃ§Ãµes	d_filtro0028	3
1309	SituaÃ§Ã£o dos pedidos	d_filtro_sit_pedidos	2
1310	Informe o nº do prÃ©-pedido ou branco para todos	d_filtro00326	3
1311	SituaÃ§Ã£o do Clientes	d_filtro_situacao_clientes	3
1312	Informe a cÃ©lula (fila) de atendimento ou branco para todas	d_filtro00115	2
1313	Informe o(s) nÃºmero(s) da nota(s) II	d_filtro00115	5
1314	Informe a sÃ©rie	d_filtro00326	2
1315	Data inÃ­cio faturamento	d_filtro00321	4
1316	% AlÃ­quota interna	d_filtro00243	1
1317	Vencimento do convÃªnio 	d_filtro0015	
1318	ConvÃªnio ou branco para todos 	d_filtro0016	
1319	Data de aniversÃ¡rio 	d_filtro0017	
1320	SituaÃ§Ã£o do cliente 	d_filtro0018	
1321	Somente produto que tem preÃ§o off-line 	d_filtro0021	
1322	CÃ³digo do produto ou branco para todos 	d_filtro0023	
1323	Produtos com preÃ§o 	d_filtro0024	
1324	LocalizaÃ§Ã£o 	d_filtro0026	
1325	Periodo de faturamento / alteraÃ§Ã£o  	d_filtro0027	
1326	Somente itens pesÃ¡veis 	d_filtro0028	
1327	Selecione a origem da movimentaÃ§Ã£o 	d_filtro0049	
1328	Data de anivesÃ¡rio do cÃ´njuge 	d_filtro00110	
1329	Informe o cÃ³digo da atividade 	d_filtro00111	
1330	RegiÃ£o ou branco para todos 	d_filtro00114	
1331	SeÃ§Ã£o ou branco para todos	d_filtro00212	
1332	PreÃ§os de atacado alterados depois de 	d_filtro00213	
1333	Somente produto com cadeia de preÃ§o	d_filtro00214	
1334	Data para auditoria de preÃ§os alterados 	d_filtro00215	
1335	Data de inÃ­cio de promoÃ§Ã£o 	d_filtro0033	
1336	EndereÃ§o ou branco para todos	d_filtro00127	
1337	Tipo de residÃªncia	d_filtro00128	
1338	Data inicial da promoÃ§Ã£o	d_filtro00219	
1339	Data final da promoÃ§Ã£o	d_filtro00219	
1340	Data para posiÃ§Ã£o	d_filtro00321	
1341	SeÃ§Ã£o ou 0 (zero) para todos	d_filtro00212	
1342	NÃºmero de dias 	d_filtro00323	
1343	NÃºmero da nota ou branco para todos	d_filtro00324	
1344	UsuÃ¡rio 	d_filtro00430	
1345	Data de alteraÃ§Ã£o dos preÃ§os	d_filtro00235	
1346	NÃºmero do cupom ou branco para todos	d_filtro00325	
1347	Data de aniversÃ¡rio final	d_filtro00321	
1348	Informe a quantidade mÃ¡xima de estoque	d_filtro_quant_minima_estoque	3
1349	NÃºmero do orÃ§amento	d_filtro00319	
1350	Tipo SituaÃ§Ã£o TributÃ¡ria 	d_filtro00240	
1351	NÃºmero do Pedido ou branco para todos	d_filtro00326	
1352	NÃºmero da CotaÃ§Ã£o	d_filtro00323	
1353	Informe o cÃ³digo da separaÃ§Ã£o	d_filtro00328	2
1354	Tipo AuxÃ­lio	d_filtro_auxilio	3
1355	Informe o c³digo final do cliente	d_filtro00326	1
1356	Informe o local de estoque que ser¡ abastecido	d_filtro00124	1
1357	Informe o cÃ³digo da bandeira	d_filtro00411	1
1358	Informe o nÃºmero de Volume	d_filtro00326	2
1359	Informe a situaÃ§Ã£o dos cheques	d_filtro0032	1
1360	Informe a regiÃ£o	d_filtro00114	1
1361	Informe o grupo de conta contÃ¡bil	d_filtro00323	1
1362	Informe o cÃ³digo do cliente	d_filtro00115	2
1363	Informe a observaÃ§Ã£o ou banco para todos	d_filtro00115	2
1364	Informe a 1a. conta contÃ¡bil	d_filtro00133	1
1365	Informe a 2a. conta contÃ¡bil	d_filtro00133	1
1366	Informe o NÃºmero do Pedido	d_filtro00326	1
1367	Informe o(s) nÃºmero(s) da nota(s) iii	d_filtro00115	4
1368	Data autorizaÃ§Ã£o inicial	d_filtro00321	2
1369	Data autorizaÃ§Ã£o final	d_filtro00322	3
1370	Informe o nº da autorizaÃ§Ã£o ou branco para todas	d_filtro00326	1
1371	Informe o mÃ³dulo do sistema ou branco para todos	d_filtro_modulos_comercializa	4
1372	Informe o veÃ­culo	d_filtro00326	3
1373	SituaÃ§Ã£o do relatÃ³rio	d_filtro_situacao_relvisita	2
1374	Tipo da autorizaÃ§Ã£o (situaÃ§Ã£o tÃ©cnica)	d_filtro_tipoautorizacao	2
1375	RelatÃ³rio de visita	d_filtro00326	2
1376	Listar Chamados Aguardando AtualizaÃ§Ã£o VersÃ£o	d_filtro0028	1
1377	DivisÃ£o tipo contrato	d_filtro_divisao_contrato	1
1378	Considerar produtos configurados como matÃ©ria-prima	d_filtro00233	1
1379	SituaÃ§Ã£o clientes	d_filtro_situacao_clientes	1
1380	Fase de negociaÃ§Ã£o	d_filtro_fasenegociacao	1
1381	Material divulgaÃ§Ã£o	d_filtro_materialdivulgacao	1
1382	Informe a Ã¡rea de alocaÃ§Ã£o	d_filtro_area_alocacao	1
1383	Exibe tÃ­tulos agrupados	d_filtro_agrupados	2
1384	Informe a divisÃ£o	d_filtro00561	1
1385	Informe a seÃ§Ã£o	d_filtro00212	1
1386	Informe o NÃºmero do cheque	d_filtro00326	1
1387	Informe o NÃºmero do TÃ­tulo ou branco para todos	d_filtro00326	1
1388	Informe o NÃºmero de Dias para SugestÃ£o	d_filtro00326	1
1389	Informe as divisÃµes ou branco para todas	d_filtro00333	2
1390	Informe as seÃ§Ãµes	d_filtro0031	1
1391	Digite a observaÃ§Ã£o 1	d_filtro00571	1
1392	Digite a observaÃ§Ã£o 2	d_filtro00571	1
1393	Digite a observaÃ§Ã£o 3	d_filtro00571	1
1394	Digite a observaÃ§Ã£o 4	d_filtro00571	1
1395	Duplicata (sim), cheque (nÃ£o)	d_filtro0028	1
1396	Informe a descriÃ§Ã£o do produto	d_filtro00115	1
1397	NÃ£o Utilizar (ERRO)	d_filtro00326	4
1398	Informe a situaÃ§Ã£o do(s) tÃ­tulo(s)	d_filtro00148	1
1399	Informe p=pendente, r=parcial, c=concluÃ­do ou branco p/ todos	d_filtro00115	3
1400	(sim)para todos (nÃ£o)somente pos	d_filtro00233	1
1401	MÃ©dia venda mes maior que	d_filtro00289	1
1402	Numero da promoÃ§Ã£o	d_filtro00326	2
1403	N° nota devoluÃ§Ã£o	d_filtro00326	2
1404	Pedido de isenÃ§Ã£o taxa	d_filtro00233	1
1405	Nome do prÃªmio	d_filtro00115	4
1406	Numero da opÃ§Ã£o	d_filtro00326	2
1407	Vencimento cartÃ£o	d_filtro00322	1
1408	ESCREVER NOME DO ESPAÃ‡O	d_filtro00115	4
1409	Mostrar produtos c/cotaÃ§Ã£o e ja pedidos	d_filtro00233	1
1410	Informe a PontuaÃ§Ã£o por Vendas	d_filtro00327	1
1411	Informe a PontuaÃ§Ã£o por Quantidade	d_filtro00327	1
1412	Informe os Locais de Retirada (Separe por vÃ­rgula)	d_filtro00115	1
1413	Informe a(s) RegiÃ£o(Ãµes) (Separe por vÃ­rgula)	d_filtro00115	1
1414	Informe o(s) CFOP(s) separados por vÃ­rgula.	d_filtro00115	1
1415	Informe a promo§£o	d_filtro00142	1
1416	Imprimir somente itens pes¡veis 	d_filtro0028	1
1417	Informe o nº do balan§o ou zero para todos	d_filtro00326	1
1418	Informe o per­odo para a data de vencimento 	d_filtro0033	2
1419	Informe o per­odo para a data de movimento 	d_filtro0033	2
1420	Informe o per­odo para a data de pagamento 	d_filtro0033	2
1421	Informe a vers£o	d_filtro00423	3
1422	Informe a localiza§£o ou branco para todas	d_filtro_depart	1
1423	Informe a regi£o ou branco para todos 	d_filtro00114	1
1424	Informe a(s) se§£o(µes) ou branco para todos 	d_filtro00212	1
1425	Informe a categoria da opera§£o interna	d_filtro_categoriacoi	4
1426	Informe a s©rie ou branco para todas	d_filtro00115	6
1427	Informe o dia do anivers¡rio	d_filtro0032	3
1428	Informe o mªs do anivers¡rio	d_filtro0042	3
1429	Informe a al­quota 	d_filtro00229	1
1430	Informe o n° da conta banc¡ria	d_filtro00411	5
1431	Informe o c³digo suframa	d_filtro00115	4
1432	Informe o endere§o ou branco para todos	d_filtro00115	1
1433	Informe o tipo de residªncia	d_filtro00128	1
1434	Informe o nº da pr©-venda	d_filtro00115	4
1435	Data para posi§£o	d_filtro00322	1
1436	Informe a situa§£o do pedido	d_filtro00432	3
1437	Informe o usu¡rio ou branco para todos	d_filtro00430	1
1438	Informe a situa§£o do agendamento	d_filtro00433	4
1439	Per­odo por atraso	d_filtro00150	6
1440	Informe o(s) usu¡rio(s) ou branco para todos	d_filtro00430	4
1441	Data de anivers¡rio inicial	d_filtro00321	1
1442	Data de anivers¡rio final	d_filtro00322	1
1443	Informe o nº do or§amento ou branco para todos	d_filtro00326	1
1444	Informe a conta banc¡ria	d_filtro00132	1
1445	Per­odo de data de nascimento	d_filtro00431	1
1446	Informe a institui§£o (administradora)	d_filtro00115	2
1447	Informe o tipo da transa§£o	d_filtro0060	2
1448	Informe a conta cont¡bil	d_filtro00133	1
1449	Informe o tipo situa§£o tribut¡ria 	d_filtro00240	1
1450	Informe a situa§£o atual do cheque	d_filtro00241	1
1451	Informe o nº da p¡gina inicial	d_filtro00289	1
1452	Data previs£o de entrega inicial	d_filtro00321	1
1453	Data previs£o de entrega final	d_filtro00322	1
1454	Data de emiss£o inicial	d_filtro00321	1
1455	Data de emiss£o final	d_filtro00322	1
1456	Selecione o m³dulo	d_filtro0050	1
1457	Data inicial do ºltimo log 	d_filtro00321	1
1458	Data final do ºltimo log	d_filtro00322	1
1459	Informe o funcion¡rio ou branco para todos	d_filtro0013	1
1460	Informe o tipo de altera§£o de pre§o	d_filtro00135	2
1461	Pre§os zerados e/ou n£o	d_filtro00136	1
1462	Pre§os em promo§£o e/ou n£o	d_filtro00137	1
1463	Informe a situa§£o de vendas futuras	d_filtro00138	1
1464	Situa§£o do cadastro do produto ativo/inativo	d_filtro00139	1
1465	Data/Hora previs£o de entrega inicial	d_filtro00140	1
1466	Data/Hora previs£o de entrega final	d_filtro00141	1
1467	Situa§£o do cnpj/cpf dos clientes	d_filtro00142	1
1468	Data de altera§£o inicial	d_filtro00321	1
1469	Data de altera§£o final	d_filtro00322	1
1470	Informe a descri§£o parcial do item	d_filtro00115	2
1471	Data de balan§o	d_filtro00322	1
1472	Situa§£o de pis/cofins	d_filtro00143	1
1473	Informe o tipo do pre§o	d_filtro00145	1
1474	Data inicial da primeira faixa de hor¡rio	d_filtro00321	1
1475	Data final da primeira faixa de hor¡rio	d_filtro00322	1
1476	Data inicial da segunda faixa de hor¡rio	d_filtro00321	1
1477	Data final da segunda faixa de hor¡rio	d_filtro00322	1
1478	Informe o tipo de c¡lculo do PIS/COFINS	d_filtro00146	2
1479	Informe o tipo de emiss£o	d_filtro00147	1
1480	Data de promo§£o inicial	d_filtro00321	1
1481	Data de promo§£o final	d_filtro00322	1
1482	Situa§£o do cadastro do cliente ativo/inativo	d_filtro00139	1
1483	Informe o % de bonifica§£o	d_filtro00131	1
1484	Informe a gerªncia ou branco para todos	d_filtro0013	1
1485	Informe o respons¡vel ou branco para todos	d_filtro0013	1
1486	Informe dias do ºltimo movimento maior que	d_filtro00289	1
1487	Informe parte da descri§£o da categoria do chamado	d_filtro00115	2
1488	Informe parte da descri§£o da situa§£o do chamado	d_filtro00115	2
1489	Informe o m³dulo	d_filtro0050	1
1490	Informe o tipo da situa§£o 	d_filtro00250	1
1491	Informe a situa§£o dos chamados pendentes/baixados	d_filtro00148	1
1492	Data de balan§o inicial	d_filtro00321	1
1493	Data de balan§o final	d_filtro00322	1
1494	Informe o patrim´nio	d_filtro0065	1
1495	Informe o nº da cota§£o	d_filtro00326	1
1496	Informe o valor m­nimo de ir	d_filtro00131	4
1497	Porcentagem p/ impress£o	d_filtro00131	3
1498	Situa§£o da duplicata	d_filtro0051	3
1499	Data de cobran§a inicial	d_filtro00321	2
1500	Data de cobran§a final	d_filtro00322	2
1501	Informe a cadeia de pre§os	d_filtro_cadeiapreco	3
1502	Observa§£o de retirada do produto	d_filtro_obsproduto	3
1503	Informe a codifica§£o dos relat³rios de invet¡rio	d_filtro00215	5
1504	Informe o per­odo para a data de promo§£o	d_filtro0033	4
1505	Data fim de promo§£o inicial	d_filtro00321	4
1506	Data fim de promo§£o final	d_filtro00322	5
1507	Informe a situa§£o de nota de transferªncia	d_filtro_situacao_nota	2
1508	Informe o nºmero da nota	d_filtro00326	2
1509	Informe a situa§£o da transa§£o	d_filtro00228	3
1510	Informe o ê da nota / mapa fiscal	d_filtro00326	3
1511	Informe o or§amento	d_filtro00326	2
1512	Informe o(s) usu¡rio(s)	d_filtro00430	2
1513	Informe o % para comiss£o	d_filtro00131	4
1514	Informe a situa§£o do patrim´nio	d_filtro240	10
1515	Custo para a valoriza§£o da diferen§a	d_filtro0241	2
1516	Informe o nºmero de dias para sugest£o de compras	d_filtro00289	4
1517	Informe o % de defla§£o	d_filtro00243	3
1518	Somente produtos com sugest£o de compras	d_filtro0028	5
1519	Informe o ­ndice de corre§£o	d_filtro00255	3
1520	Percentual de acr©scimo a ser aplicado	d_filtro00256	2
1521	Situa§£o	d_filtro00148	4
1522	Tipo de c¡lculo do pis/cofins	d_filtro00201	2
1523	G´ndola (ou branco para todas)	d_filtro00200	3
1524	Informe o c³digo da fam­lia	d_filtro00210	2
1525	Data inicial per­odo anterior	d_filtro00321	3
1526	Data final per­odo anterior	d_filtro00322	3
1527	Informe a fam­lia	d_filtro00210	7
1528	Informe a(s) divis£o(µes) ou branco para todos	d_filtro00561	5
1529	Informe o mªs	d_filtro_mes	3
1530	Informe a descri§£o do cabe§alho 	d_filtro00115	4
1531	Informe o grupo econ´mico	d_filtro_grupo_economico	4
1532	Informe o(s) grupos de usu¡rio(s) ou branco todos 	d_filtro00430	3
1533	Informe a al­quota de entrada	d_filtro00229	4
1534	Informe a al­quota de sa­da	d_filtro00229	6
1535	Informe as divisµes ou branco para todas	d_filtro00335	2
1536	Informe a quantidade inicial de venda ou branco todas (1° per­odo)	d_filtro00326	2
1537	Informe a quantidade inicial de venda ou branco todas (2° per­odo)	d_filtro00326	2
1538	Situa§£o da ordem de servi§o	d_filtro00151	2
1539	Informe o nº da ordem de servi§o	d_filtro00152	4
1540	Informe o respons¡vel	d_filtro00430	3
1541	Informe a localiza§£o do patrimonio	d_filtro00291	2
1542	Informe a quantidade m­nima de estoque	d_filtro_quant_minima_estoque	3
1543	Informe o status do m³dulo	d_filtro0068	2
1544	Informe a situa§£o atual do cheque	d_filtro_situacao_cheque	2
1545	Informe o nºmero da encomenda	d_filtro00446	3
1546	Produtos em promo§£o:	d_filtro00207	3
1547	Informe o motivo da devolu§£o	d_filtro00115	2
1548	Informe o nº do V£o ou branco para todos	d_filtro00326	4
1549	Informe a ¡rea	d_filtro00447	2
1550	Informe a bonifica§£o	d_filtro00326	2
1551	Informe a(s) forma(s) de pagto que n£o deve listar	d_filtro0036	3
1552	Somente Produtos com Pr©-Pedido(s) Pendente(s)	d_filtro_produto_pendente_prepedido	2
1553	Status da negocia§£o	d_filtro00563	3
1554	Tipo do pre§o	d_filtro00564	2
1555	Prazo da negocia§£o	d_filtro00565	2
1556	Informe a s©rie	d_filtro00566	2
1557	Informe o nº do pr©-pedido ou branco para todos	d_filtro_nro_prepedido	2
1558	Situa§£o do(s) Pr©-Pedido(s)	d_filtro_situacao_prepedido	2
1559	Informe o nº da autoriza§£o	d_filtro00229	2
1560	Informe a(s) Cta(s) Cont¡bil(s) ou branco p/ todos	d_filtro00439	5
1561	Tipo de Pre§o Pr©-Pedido	d_filtro_tipo_preco_prepedido	2
1562	Situa§£o do Clientes	d_filtro0018	4
1563	Tipo da Nota de Transferªncia	d_filtro00356	2
1564	Avalia§£o do atendente	d_filtro00361	3
1565	Avalia§£o da ferramenta de atendimento	d_filtro00361	2
1566	Informe a c©lula de atendimento ou branco p/ todas	d_filtro00115	4
1567	Informe o(s) COI de sa­da 1	d_filtro00120	6
1568	Informe o(s) COI de sa­da 2	d_filtro00120	6
1569	Tipo Solicita§£o	d_filtro00155	2
1570	Informe o cÃódigo inicial do cliente	d_filtro00326	1
1571	1º data para posi§£o de estoque	d_filtro00322	2
1572	2º data para posi§£o de estoque	d_filtro00322	2
1573	Situa§£o pis/cofins	d_filtro00568	2
1574	Situa§£o tribut¡ria	d_filtro00569	2
1575	Data de produ§£o inicial	d_filtro00321	2
1576	Data de produ§£o final	d_filtro00322	3
1577	Informe o % de varia§£o de custo inicial	d_filtro00131	4
1578	Informe o % de varia§£o de custo final	d_filtro00131	2
1579	Digite a observa§£o	d_filtro00571	2
1580	Quantidade de produtos por divis£o a listar	d_filtro00326	4
1581	Informe a empresa de produ§£o	d_filtro0031	6
1582	Informe o nº do caixa que n£o deve mostrar 	d_filtro00326	4
1583	Listar somente produtos com divergªncia	d_filtro0028	3
1584	Mostra t­tulos da tesouraria	d_filtro00438	3
1585	Situa§£o do pedido	d_filtro00410	4
1586	Situa§£o da bonifiaca§£o	d_filtro0562	3
1587	Tipo da Bonifica§£o	d_filtro0563	3
1588	Informe a rede de neg³cios	d_filtro_rede_negocio	2
1589	Informe a situa§£o da entrega	d_filtro_situacaologistica	3
1590	Informe a conta cont¡bil (cr©dito) de troco	d_filtro00133	4
1591	Informe a conta cont¡bil (cr©dito)  de contra-vale	d_filtro00133	4
1592	Classifica§£o(µes) cont¡bil(eis) ou branco p/ todas	d_filtro00440	4
1593	Informa o nºmero da remessa	d_filtro00566	2
1594	Informe a situa§£o de cobran§a	d_filtro_situacao_cobranca	3
1595	Informe o c³digo da separa§£o	d_filtro00326	3
1596	Informe o hist³rico cont¡bil	d_filtro_historico_contabil	3
1597	Informe a situaÃ§Ã£o do crédito do cliente 	d_filtro0018	1
1598	Informe o cÃódigo final do cliente	d_filtro00326	1
1599	Informe o nºmero da autoriza§£o	d_filtro00326	2
1600	Somente servi§os	d_filtro_flagIss	3
1601	Tipo classifica§£o	d_filtro_classificacao_ctba	2
1602	Informe a situa§£o atual dos cheques	d_filtro_situacao_atual_cheque	3
1603	Informe o(s) or§amento(s)	d_filtro00452	7
1604	Informe a situa§£o das vendas futuras 	d_filtro00453	4
1605	Situa§£o notas	d_filtro_notas_servico_canceladas	2
1606	Tipo relat³rio	d_filtro00457	3
1607	Produtos com sugest£o de compras	d_filtro00576	2
1608	Somente notas com divergªncia	d_filtro0028	4
1609	Vers£o	d_filtro00566	2
1610	% Al­quota interna	d_filtro_aliquota_interna	4
1611	Informe o ve­culo	d_filtro_veiculo	2
1612	Nª do registro de sa­da	d_filtro00289	2
1613	Situa§£o do Estoque	d_filtro00580	2
1614	Situa§£o	d_filtro00139	1
1615	Dias para c¡lculo da m©dia di¡ria de venda	d_filtro00289	2
1616	Dias para c¡lculo de excesso	d_filtro00289	2
1617	Dias para c¡lculo de faltas	d_filtro00289	2
1618	Considerar acr©scimos no c¡lculo da comiss£o	d_filtro0028	1
1619	Informe o nº da Pr©-Carga	d_filtro00326	2
1620	Subtrair as devolu§µes	d_filtro00233	2
1621	Situa§£o cheques conciliados	d_filtro00581	2
1622	Selecione o grupo de patrim´nios	d_filtro00491	2
1623	Informe o tipo do patrim´nio	d_filtro00584	3
1624	Informe o nºmero do livro	d_filtro00326	2
1625	Considerar produtos configurados como patrim´nio	d_filtro00233	4
1626	Digite o per­odo para a data de vencimento 	d_filtro0033	1
1627	Informe o(s) usu¡rio(s) que n£o deve mostrar	d_filtro00430	2
1628	Situa§£o do cr©dito do cliente 	d_filtro0018	1
1629	Situa§£o atual do cheque	d_filtro00241	1
1630	Situa§£o de vendas futuras	d_filtro00138	1
1631	Informe o COI de Sa­da 1	d_filtro00119	4
1632	Informe o COI de Sa­da 2	d_filtro00119	4
1633	Informe o tipo de promo§£o	d_filtro00142	
1634	Informe a localiza§£o do patrimonio	d_filtro0070	8
1635	Inform a situa§£o do produto	d_filtro00333	2
1636	Informe a data inicial do primeiro per­odo	d_filtro00321	2
1637	Informe a data final do primeiro per­odo	d_filtro00322	2
1638	Informe a data inicial do segundo per­odo	d_filtro00321	2
1639	Informe a data final do segundo per­odo	d_filtro00322	2
1640	Informe a(s) divis£o(µes) ou branco para todas	d_filtro00213	4
1641	Situa§£o do cadastro de produto novo/reativado	d_filtro00334	1
1642	Digite o per­odo para a data de movimento 	d_filtro0033	1
1643	Digite o per­odo para a data de pagamento 	d_filtro0033	1
1644	Digite a institui§£o (administradora)	d_filtro00115	1
1645	Tipo da transa§£o	d_filtro0060	1
1646	Tipo de altera§£o de pre§o	d_filtro00135	1
1647	Digite a descri§£o parcial do item	d_filtro00115	1
1648	Tipo de c¡lculo do pis/cofins	d_filtro00146	
1649	Informe a situa§£o do chamado	d_filtro00115	1
1650	Selecione o grupo de patrim´nios	d_filtro00581	1
1651	Informe a situa§£o do patrimonio	d_filtro00290	4
1652	Informe a situa§£o do produto	d_filtro00333	3
1653	Produto / Servi§o	d_filtro_produto_servico	8
1654	Informe a(s) divis£o(µes) ou branco para todos	d_filtro00211	2
1655	Informe a quantidade inicial de venda (1° per­odo)	d_filtro00326	3
1656	Informe a quantidade inicial de venda (2° per­odo)	d_filtro00326	3
1657	Formas de pagamento   vista	d_filtro00257	3
1658	Situa§£o do cliente no cart£o pr³prio ativo/inativo	d_filtro00139	4
1659	Tipo de cart£o (d©bito/cr©dito/ambos)	d_filtro0060	2
1660	Data de digita§£o inicial	d_filtro00321	2
1661	Data de digita§£o final	d_filtro00322	2
1662	Data inicial de aquisi§£o	d_filtro00321	1
1663	Data final de aquisi§£o	d_filtro00322	1
1664	Informe o(s) motivo(s) de devolu§£o	d_filtro00585	1
1665	Informe a situa§£o da lista	d_filtro_situacao_lista	3
1666	Pre§o Promo§£o:	d_filtro00207	4
1667	Informe a localiza§£o do patrim´nio	d_filtro_localizacaopatrimonio	5
1668	Informe a orienta§£o do papel	d_filtro00252	2
1669	Informe a(s) se§£o(µes)	d_filtro00212	3
1670	Data movimenta§£o inicial	d_filtro00321	2
1671	Data movimenta§£o final	d_filtro00321	2
1672	Data de lan§amento Inicial	d_filtro00321	4
1673	Data de lan§amento Final	d_filtro00322	2
1674	Informe o nºmero do t­tulo	d_filtro00326	2
1675	Informe a codifica§£o dos relat³rios de invent¡rio	d_filtro00215	6
1676	Informe a Data para auditoria de pre§os alterados 	d_filtro00215	
1677	Pre§os alterados depois de  	d_filtro00216	
1678	Pre§os n£o alterados desde	d_filtro00217	
1679	Informe o per­odo para data de in­cio de promo§£o 	d_filtro0033	
1680	Produtos export¡veis para frente de caixa 	d_filtro00230	
1681	Informe a data final da promo§£o	d_filtro00219	
1682	Informe a se§£o ou 0 (zero) para todos	d_filtro00212	
1683	Dig­te o periodo para a data de pagamento	d_filtro0017	
1684	Informe a Situa§£o Tecnica	d_filtro_situacaotecnica	1
1685	Informe o(s) motivo(s) de devolu§£o	d_filtro_motivo_dev	1
1686	Informe o mªs de nascimento	d_filtro00401	
1687	Informe uma se§£o	d_filtro00212	
1688	Se§£o ou 0 para todas 	d_filtro00234	
1689	Informe a senha do usu¡rio do vendedor	d_filtro_senha	10
1690	Informe a quantidade m­nima de giro	d_filtro00327	4
1691	Calcular m©dia di¡ria dos ºltimos	d_filtro00289	1
1692	Nª registro de sa­da	d_filtro00289	1
1693	Situa§£o de Concilia§£o de Cheques	d_filtro00581	1
1694	Informe o(s) nºmero(s) da nota(s)	d_filtro00115	4
1695	Informe o(s) nºmero(s) da nota(s) I	d_filtro00115	7
1696	Informe o(s) nºmero(s) da nota IV	d_filtro00115	4
1697	Informe o respons¡vel	d_filtro00153	2
1698	Situa§£o Agendamento	d_filtro00433	3
1699	Considerar devolu§µes	d_filtro0028	3
1700	Situa§£o dos pedidos	d_filtro_sit_pedidos	2
1701	Informe o nº do pr©-pedido ou branco para todos	d_filtro00326	3
1702	Situa§£o do Clientes	d_filtro_situacao_clientes	3
1703	Informe a c©lula (fila) de atendimento ou branco para todas	d_filtro00115	2
1704	Informe o(s) nºmero(s) da nota(s) II	d_filtro00115	5
1705	Informe a s©rie	d_filtro00326	2
1706	% Al­quota interna	d_filtro00243	1
1707	Vencimento do convªnio 	d_filtro0015	
1708	Convªnio ou branco para todos 	d_filtro0016	
1709	Data de anivers¡rio 	d_filtro0017	
1710	Situa§£o do cliente 	d_filtro0018	
1711	Somente produto que tem pre§o off-line 	d_filtro0021	
1712	C³digo do produto ou branco para todos 	d_filtro0023	
1713	Produtos com pre§o 	d_filtro0024	
1714	Localiza§£o 	d_filtro0026	
1715	Periodo de faturamento / altera§£o  	d_filtro0027	
1716	Somente itens pes¡veis 	d_filtro0028	
1717	Selecione a origem da movimenta§£o 	d_filtro0049	
1718	Data de anives¡rio do c´njuge 	d_filtro00110	
1719	Informe o c³digo da atividade 	d_filtro00111	
1720	Regi£o ou branco para todos 	d_filtro00114	
1721	Se§£o ou branco para todos	d_filtro00212	
1722	Pre§os de atacado alterados depois de 	d_filtro00213	
1723	Somente produto com cadeia de pre§o	d_filtro00214	
1724	Data para auditoria de pre§os alterados 	d_filtro00215	
1725	Data de in­cio de promo§£o 	d_filtro0033	
1726	Endere§o ou branco para todos	d_filtro00127	
1727	Tipo de residªncia	d_filtro00128	
1728	Data inicial da promo§£o	d_filtro00219	
1729	Data final da promo§£o	d_filtro00219	
1730	Data para posi§£o	d_filtro00321	
1731	Se§£o ou 0 (zero) para todos	d_filtro00212	
1732	Nºmero de dias 	d_filtro00323	
1733	Nºmero da nota ou branco para todos	d_filtro00324	
1734	Usu¡rio 	d_filtro00430	
1735	Data de altera§£o dos pre§os	d_filtro00235	
1736	Nºmero do cupom ou branco para todos	d_filtro00325	
1737	Data de anivers¡rio final	d_filtro00321	
1738	Informe a quantidade m¡xima de estoque	d_filtro_quant_minima_estoque	3
1739	Nºmero do or§amento	d_filtro00319	
1740	Tipo Situa§£o Tribut¡ria 	d_filtro00240	
1741	Nºmero do Pedido ou branco para todos	d_filtro00326	
1742	Nºmero da Cota§£o	d_filtro00323	
1743	Informe o c³digo da separa§£o	d_filtro00328	2
1744	Tipo Aux­lio	d_filtro_auxilio	3
1745	Informe o mÃªs do aniversário	d_filtro0042	3
1746	Informe o cÃódigo suframa	d_filtro00115	4
1747	Informe o c³digo da bandeira	d_filtro00411	1
1748	Informe o nºmero de Volume	d_filtro00326	2
1749	Informe a situa§£o dos cheques	d_filtro0032	1
1750	Informe a regi£o	d_filtro00114	1
1751	Informe o grupo de conta cont¡bil	d_filtro00323	1
1752	Informe o c³digo do cliente	d_filtro00115	2
1753	Informe a observa§£o ou banco para todos	d_filtro00115	2
1754	Informe a 1a. conta cont¡bil	d_filtro00133	1
1755	Informe a 2a. conta cont¡bil	d_filtro00133	1
1756	Informe o Nºmero do Pedido	d_filtro00326	1
1757	Informe o(s) nºmero(s) da nota(s) iii	d_filtro00115	4
1758	Data autoriza§£o inicial	d_filtro00321	2
1759	Data autoriza§£o final	d_filtro00322	3
1760	Informe o nº da autoriza§£o ou branco para todas	d_filtro00326	1
1761	Informe o m³dulo do sistema ou branco para todos	d_filtro_modulos_comercializa	4
1762	Informe o ve­culo	d_filtro00326	3
1763	Situa§£o do relat³rio	d_filtro_situacao_relvisita	2
1764	Tipo da autoriza§£o (situa§£o t©cnica)	d_filtro_tipoautorizacao	2
1765	Relat³rio de visita	d_filtro00326	2
1766	Listar Chamados Aguardando Atualiza§£o Vers£o	d_filtro0028	1
1767	Divis£o tipo contrato	d_filtro_divisao_contrato	1
1768	Considerar produtos configurados como mat©ria-prima	d_filtro00233	1
1769	Situa§£o clientes	d_filtro_situacao_clientes	1
1770	Fase de negocia§£o	d_filtro_fasenegociacao	1
1771	Material divulga§£o	d_filtro_materialdivulgacao	1
1772	Informe a ¡rea de aloca§£o	d_filtro_area_alocacao	1
1773	Exibe t­tulos agrupados	d_filtro_agrupados	2
1774	Informe a divis£o	d_filtro00561	1
1775	Informe a se§£o	d_filtro00212	1
1776	Informe o Nºmero do cheque	d_filtro00326	1
1777	Informe o Nºmero do T­tulo ou branco para todos	d_filtro00326	1
1778	Informe o Nºmero de Dias para Sugest£o	d_filtro00326	1
1779	Informe as divisµes ou branco para todas	d_filtro00333	2
1780	Informe as se§µes	d_filtro0031	1
1781	Digite a observa§£o 1	d_filtro00571	1
1782	Digite a observa§£o 2	d_filtro00571	1
1783	Digite a observa§£o 3	d_filtro00571	1
1784	Digite a observa§£o 4	d_filtro00571	1
1785	Duplicata (sim), cheque (n£o)	d_filtro0028	1
1786	Informe a descri§£o do produto	d_filtro00115	1
1787	N£o Utilizar (ERRO)	d_filtro00326	4
1788	Informe a situa§£o do(s) t­tulo(s)	d_filtro00148	1
1789	Emiss£o Impresso	d_filtro00322	1
1790	Informe p=pendente, r=parcial, c=conclu­do ou branco p/ todos	d_filtro00115	3
1791	(sim)para todos (n£o)somente pos	d_filtro00233	1
1792	M©dia venda mes maior que	d_filtro00289	1
1793	Numero da promo§£o	d_filtro00326	2
1794	N° nota devolu§£o	d_filtro00326	2
1795	Pedido de isen§£o taxa	d_filtro00233	1
1796	Nome do prªmio	d_filtro00115	4
1797	Numero da op§£o	d_filtro00326	2
1798	Vencimento cart£o	d_filtro00322	1
1799	ESCREVER NOME DO ESPA‡O	d_filtro00115	4
1800	Mostrar produtos c/cota§£o e ja pedidos	d_filtro00233	1
1801	Informe a Pontua§£o por Vendas	d_filtro00327	1
1802	Informe a Pontua§£o por Quantidade	d_filtro00327	1
1803	Informe os Locais de Retirada (Separe por v­rgula)	d_filtro00115	1
1804	Informe a(s) Regi£o(µes) (Separe por v­rgula)	d_filtro00115	1
1805	Informe o(s) CFOP(s) separados por v­rgula.	d_filtro00115	1
1806	Informe o tipo situaÃ§Ã£o tributária 	d_filtro00240	1
1807	Selecione o mÃódulo	d_filtro0050	1
1808	Informe o mÃódulo	d_filtro0050	1
1809	Informe a codificaÃ§Ã£o dos relatÃórios de invetário	d_filtro00215	5
1810	Informe o período para a data de promoÃ§Ã£o	d_filtro0033	4
1811	Informe o índice de correÃ§Ã£o	d_filtro00255	3
1812	Informe o cÃódigo da família	d_filtro00210	2
1813	Informe o status do mÃódulo	d_filtro0068	2
1814	SituaÃ§Ã£o do(s) Pré-Pedido(s)	d_filtro_situacao_prepedido	2
1815	Tipo de PreÃ§o Pré-Pedido	d_filtro_tipo_preco_prepedido	2
1816	SituaÃ§Ã£o tributária	d_filtro00569	2
1817	Informe a rede de negÃócios	d_filtro_rede_negocio	2
1818	ClassificaÃ§Ã£o(Ãµes) contábil(eis) ou branco p/ todas	d_filtro00440	4
1819	Informe o cÃódigo da separaÃ§Ã£o	d_filtro00326	3
1820	Informe o histÃórico contábil	d_filtro_historico_contabil	3
1821	Tipo relatÃório	d_filtro00457	3
1822	Considerar acréscimos no cálculo da comissÃ£o	d_filtro0028	1
1823	Informe o(s) usuário(s) que nÃ£o deve mostrar	d_filtro00430	2
1824	SituaÃ§Ã£o do crédito do cliente 	d_filtro0018	1
1825	SituaÃ§Ã£o do cliente no cartÃ£o prÃóprio ativo/inativo	d_filtro00139	4
1826	Tipo de cartÃ£o (débito/crédito/ambos)	d_filtro0060	2
1827	Informe o nÃºmero do título	d_filtro00326	2
1828	Informe a codificaÃ§Ã£o dos relatÃórios de inventário	d_filtro00215	6
1829	Informe o período para data de início de promoÃ§Ã£o 	d_filtro0033	
1830	Calcular média diária dos Ãºltimos	d_filtro00289	1
1831	CÃódigo do produto ou branco para todos 	d_filtro0023	
1832	Data de anivesário do cÃ´njuge 	d_filtro00110	
1833	Informe o cÃódigo da atividade 	d_filtro00111	
1834	Data de início de promoÃ§Ã£o 	d_filtro0033	
1835	Tipo SituaÃ§Ã£o Tributária 	d_filtro00240	
1836	Informe o cÃódigo da separaÃ§Ã£o	d_filtro00328	2
1837	Informe o cÃódigo da bandeira	d_filtro00411	1
1838	Informe o cÃódigo do cliente	d_filtro00115	2
1839	Informe o mÃódulo do sistema ou branco para todos	d_filtro_modulos_comercializa	4
1840	SituaÃ§Ã£o do relatÃório	d_filtro_situacao_relvisita	2
1841	Tipo da autorizaÃ§Ã£o (situaÃ§Ã£o técnica)	d_filtro_tipoautorizacao	2
1842	RelatÃório de visita	d_filtro00326	2
1843	Informe a área de alocaÃ§Ã£o	d_filtro_area_alocacao	1
1844	Informe o NÃºmero do Título ou branco para todos	d_filtro00326	1
1845	Informe a situaÃ§Ã£o do(s) título(s)	d_filtro00148	1
1846	Informe a(s) RegiÃ£o(Ãµes) (Separe por vírgula)	d_filtro00115	1
1847	Informe a(s) seção(µes) ou branco para todos 	d_filtro00212	1
1848	Informe a categrega inicial	d_filtro00321	1
1849	Informe o tipo de alteração de pre§o	d_filtro00135	2
1850	Pre§os em promoção e/ou n£o	d_filtro00137	1
1851	Informe a codificação dos relatórios de invet¡rio	d_filtro00215	5
1852	Informe o per­odo para a data de promoção	d_filtro0033	4
1853	Informe a situação de nota de transferªncia	d_filtro_situacao_nota	2
1854	Informe a codificaÃ§Ã£o dos relatórios de invetário	d_filtro00215	5
1855	Informe a situação do patrim´nio	d_filtro240	10
1856	Custo para a valorização da diferen§a	d_filtro0241	2
1857	Informe o ­ndice de correção	d_filtro00255	3
1858	Informe o código da fam­lia	d_filtro00210	2
1859	Informe a descrição do cabe§alho 	d_filtro00115	4
1860	Situação da ordem de servi§o	d_filtro00151	2
1861	Tipo de Pre§o Pré-Pedido	d_filtro_tipo_preco_prepedido	2
1862	Situação tribut¡ria	d_filtro00569	2
1863	Informe a conta cont¡bil (crédito) de troco	d_filtro00133	4
1864	Informe a conta cont¡bil (crédito)  de contra-vale	d_filtro00133	4
1865	Classificação(µes) cont¡bil(eis) ou branco p/ todas	d_filtro00440	4
1866	Informe a situação de cobran§a	d_filtro_situacao_cobranca	3
1867	Informe o histórico cont¡bil	d_filtro_historico_contabil	3
1868	Informe o código da separaÃ§Ã£o	d_filtro00326	3
1869	Informe o nºmero da autorização	d_filtro00326	2
1870	Dias para c¡lculo da média di¡ria de venda	d_filtro00289	2
1871	Considerar acréscimos no c¡lculo da comiss£o	d_filtro0028	1
1872	Tipo de alteração de pre§o	d_filtro00135	1
1873	Situação do cliente no cart£o próprio ativo/inativo	d_filtro00139	4
1874	Tipo de cart£o (débito/crédito/ambos)	d_filtro0060	2
1875	Pre§o Promoção:	d_filtro00207	4
1876	Informe a localização do patrim´nio	d_filtro_localizacaopatrimonio	5
1877	Informe a(s) seção(µes)	d_filtro00212	3
1878	Informe a codificação dos relatórios de invent¡rio	d_filtro00215	6
1879	Informe o per­odo para data de in­cio de promoção 	d_filtro0033	
1880	Calcular média di¡ria dos ºltimos	d_filtro00289	1
1881	Data de in­cio de promoção 	d_filtro0033	
1882	Data de alteração dos pre§os	d_filtro00235	
1883	Tipo Situação Tribut¡ria 	d_filtro00240	
1884	Nºmero da Cotação	d_filtro00323	
1885	SituaÃ§Ã£o do cliente no cartÃ£o próprio ativo/inativo	d_filtro00139	4
1886	Informe a codificaÃ§Ã£o dos relatórios de inventário	d_filtro00215	6
1887	Listar Chamados Aguardando Atualização Vers£o	d_filtro0028	1
1888	Informe a ¡rea de alocação	d_filtro_area_alocacao	1
1889	Informe a situação do(s) t­tulo(s)	d_filtro00148	1
1890	Informe o código da separaÃ§Ã£o	d_filtro00328	2
1891	SituaÃ§Ã£o do relatório	d_filtro_situacao_relvisita	2
1892	Pesquisar por ê	d_filtro00578	2
1893	Informe o ê do manifesto	d_filtro00326	2
1894	ê do registro de entrada	d_filtro00289	2
1895	ê do registro de saída	d_filtro00289	2
1896	Informe o ê da nota/cupom fiscal	d_filtro00326	3
1897	Informe o ã ou branco para todos	d_filtro00115	1
1898	ê registro de entrada	d_filtro00289	1
1899	ê registro de saída	d_filtro00289	1
1900	Informe o conênio ou branco para todos 	d_filtro0016	1
1901	Informe a geência ou branco para todos	d_filtro0013	1
1902	Informe a situação de nota de transfeência	d_filtro_situacao_nota	2
1903	Informe o ês do aniversário	d_filtro0042	3
1904	Informe o ês	d_filtro_mes	3
1905	Tipo da Nota de Transfeência	d_filtro00356	2
1906	Classificação(µes) contábil(eis) ou branco p/ todas	d_filtro00440	4
1907	ã ou branco para todos	d_filtro00127	
1908	ê do registro de sa­da	d_filtro00289	2
1909	Considerar acréscimos no cálculo da comiss£o	d_filtro0028	1
1910	Informe o(s) usuário(s) que n£o deve mostrar	d_filtro00430	2
1911	Informe o ês de nascimento	d_filtro00401	
1912	Calcular média diária dos ºltimos	d_filtro00289	1
1913	ê registro de sa­da	d_filtro00289	1
1914	Vencimento do conênio 	d_filtro0015	
1915	Conênio ou branco para todos 	d_filtro0016	
1916	Data de anivesário do c´njuge 	d_filtro00110	
1917	Preços zerados e/ou n£o	d_filtro00136	1
1918	Preços em promoção e/ou n£o	d_filtro00137	1
1919	Nome do pêmio	d_filtro00115	4
1920	Emissão Impresso	d_filtro00322	1
1921	Informe a(s) divis£o(ões) ou branco para todos	d_filtro00561	5
1922	Informe a(s) divis£o(ões) ou branco para todas	d_filtro00213	4
1923	Informe a(s) divis£o(ões) ou branco para todos	d_filtro00211	2
1924	Informe o nºmero do título	d_filtro00326	2
1925	Preços n£o alterados desde	d_filtro00217	
1926	Tipo de resiência	d_filtro00128	
1927	Nºmero do orçamento	d_filtro00319	
1928	Informe a situação do crÃ©dito do cliente 	d_filtro0018	1
1929	Informe parte da descriÃ§Ã£o da situação do chamado	d_filtro00115	2
1930	Informe o Nºmero do Título ou branco para todos	d_filtro00326	1
1931	Informe a(s) Regi£o(ões) (Separe por vírgula)	d_filtro00115	1
1932	Informe a situação de nota de transferÃªncia	d_filtro_situacao_nota	2
1933	Informe a situação do patrimÃ´nio	d_filtro240	10
1934	Informe o código da famÃ­lia	d_filtro00210	2
1935	Informe a alíquota de saÃ­da	d_filtro00229	6
1936	situação da ordem de serviÃ§o	d_filtro00151	2
1937	situação da bonifiacaÃ§Ã£o	d_filtro0562	3
1938	Informe a conta contábil (crÃ©dito) de troco	d_filtro00133	4
1939	Informe a conta contábil (crÃ©dito)  de contra-vale	d_filtro00133	4
1940	Informe a situação de cobranÃ§a	d_filtro_situacao_cobranca	3
1941	Informe o histÃ³rico contábil	d_filtro_historico_contabil	3
1942	situação do crÃ©dito do cliente 	d_filtro0018	1
1943	situação do cliente no cartÃ£o prÃ³prio ativo/inativo	d_filtro00139	4
1944	PreÃ§o promoção:	d_filtro00207	4
1945	Informe o Período para data de inÃ­cio de promoção 	d_filtro0033	
1946	situação de ConciliaÃ§Ã£o de Cheques	d_filtro00581	1
1947	Data de inÃ­cio de promoção 	d_filtro0033	
1948	Data de alteraÃ§Ã£o dos Preços	d_filtro00235	
1949	situação do relatÃ³rio	d_filtro_situacao_relvisita	2
1950	Tipo da autorizaÃ§Ã£o (situação tÃ©cnica)	d_filtro_tipoautorizacao	2
1951	Informe a situação do(s) tÃ­tulo(s)	d_filtro00148	1
1952	situação do cliente no cartÃ£o prÃóprio ativo/inativo	d_filtro00139	4
1953	situação do relatÃório	d_filtro_situacao_relvisita	2
1954	Tipo da autorizaÃ§Ã£o (situação técnica)	d_filtro_tipoautorizacao	2
1955	situação do cliente no cartÃ£o próprio ativo/inativo	d_filtro00139	4
1956	Informe o tipo de resiência	d_filtro00128	1
1957	Clientes para Avisar Vencimento	d_filtro0028	2
1958	Efetivado (Sim/Não)	d_filtro0028	1
1959	Informe a categoria da operacao interna	d_filtro_categoriacoi	4
1960	Informe o localRetirada	d_filtro00217	2
1961	Informe o valor do frete	d_filtro00131	1
1962	Informe os Clientes	d_filtro0013	1
1963	Informe a Placa	d_filtro00115	1
1964	Informe a marca	d_filtro_marca	1
1965	Observação 	d_filtro000115	6
1966	Informe a(s) divisão(ões) ou branco para todos	d_filtro00335	2
1967	Informe o Numero Encarte,Lamina Ou Oferta	d_filtro00326	2
1968	Data/hora de movimento final	d_filtro00141	3
1969	Fornecedor ultima compra	d_filtro0028	1
1970	Informe o tipo de categoria do(s) chamado(s)	d_filtro5000	5
1971	Data da relEAS.e inicial	d_filtro00321	1
1972	Data da relEAS.e final	d_filtro00322	1
1973	RelEAS.e	d_filtro00115	3
1974	Informe o dia de vencimento ou branco para todos 	d_filtro00115	1
1975	Informe o nosso numero ou branco para todos 	d_filtro00115	1
1976	Informe a(s) empresa(s) solicitante(s)	d_filtro0031	1
1977	Informe a(s) empresa(s) fornecedora(s)	d_filtro0031	1
1978	Informe a(s) marca(s) ou branco para todos	d_filtro_marcafabricante	1
1979	Somente COIs com Operações	d_filtro000116	1
1980	Informe a data inicial para validade da chave	d_filtro00321	3
1981	Informe o nº da condicional	d_filtro00326	1
1982	Informe a data final para validade da chave	d_filtro00322	3
1983	Informe a data inicial para geração da chave	d_filtro00321	3
1984	Informe a data final para geração da chave	d_filtro00322	2
1985	Informe a finalidade de geração da chave	d_filtro00303	3
1986	Numero Promocao	d_filtro00326	2
1987	Apresentar todos Produtos	d_filtro00233	1
1988	Informe a Placa	d_filtro00131	3
1989	Digite o(s) NCM(s) ou branco para todos	d_filtro000115	2
1990	Data de obito do individuo 	d_filtro00110	
1991	Informe o Vendedor 3	d_filtro00126	1
1992	Informe o %FCEP ou branco para 0%	d_filtro00131	3
1993	Informe o N° da Pré-Devolução	d_filtro00323	1
1994	Informe o nº da pré-carga	d_filtro00115	1
1995	Informe o tipo da Operação 	d_filtro000121	1
1996	Informe FORNECEDOR, DESPESAS ou AMBOS	d_filtro00115	4
1997	Informe AMBAS, ORIGEM ou DIGITADA	d_filtro00115	4
1998	Digite o Nome da Requisição	d_filtro00115	1
1999	Informe os dias de estoque	d_filtro00289	1
2000	Informe a descrição do Balanço	d_filtro00115	2
2001	Informe a alIquota de saída	d_filtro00229	1
2002	Informe a alIquota de icms subst	d_filtro00229	1
2003	Informe a série ou branco para todas	d_filtro0011150228	6
2004	Cst (entrada e saida)	d_cst_piscofins	2
2005	Informe o tipo de situação tributária de entrada	d_filtro00240	1
2006	Informe o tipo de situação tributária de saída	d_filtro00240	1
2007	QTD Parcelas Cartão	d_filtro00326	3
2008	Informe o código CISS do cliente/fornecedor 	d_filtro0013	2
2009	Informe o Nº do Cheque ou Branco para Todos	d_filtro00326	2
2010	Informe o Valor de Venda	d_filtro00326	1
2011	Produtos a Serem Ignorados	d_filtro00115	3
2012	Informe o(s) cliente(s) ou branco para todos	d_filtro00115	1
2013	Informe o vendedor 1	d_filtro00126	1
2014	Informe o vendedor 2	d_filtro00126	1
2015	Informe os Produtos (Separe por Vírgula)	d_filtro00115	1
2016	Informe os Produtos	d_filtro00115	1
2017	Informe a combinação combo	d_filtro00326	1
2018	Informe a combinação combo	d_filtro000119	1
2019	Informe os Locais de Retirada (Separe por v?rgula)	d_filtro00115	1
2020	Informe o CFOP ou Branco para Todos	d_filtro00326	2
2021	Considerar Impostos de Compra/Venda	d_filtro0028	3
2022	Somente produtos sem venda desde a ultima compra	d_filtro0028	1
2023	Informe o clube ou branco para todos	d_filtro_clubebeneficio	1
2024	Código da base de cálculo de crédito	d_base_calculo_credito	2
2025	Informe o tipo	d_filtro000118	1
2026	Deseja Imprimir o Custo ? 	d_filtro0028	1
2027	Informe o Número da Sugestão	d_filtro00326	
2028	Informe a Rua 	d_filtro000115	6
2029	Informe o Limite de Credito Final	d_filtro00229	2
2030	Informe o Limite de Credito Inicial	d_filtro00566	2
2031	Informe a Placa ou Branco para todos	d_filtro00115	1
2032	Data Inicial de Cadastro	d_filtro00321	2
2033	Data Final de Cadastro	d_filtro00321	2
2034	Informe o Bordero ou 0 para Todos	d_filtro00571	1
2035	Cst (Entrada e Saída) 	d_filtro00326	1
2036	Informe a série ou branco para todas	d_filtro0011150330	6
2037	Dias de Estoque maior igual 	d_filtro00289	2
2038	Mostrar Divergências	d_filtro00233	1
2039	Informe a Meta 4	d_filtro00327	1
2040	Informe o Gerente\\Subgerente da Liberação	d_filtro00430	1
2041	Informe o ajudante ou branco para todos	d_filtro0013	2
2042	Informe a situação do cliente ou branco para todos	d_situacaocliente	2
2043	Data de balanço 1	d_filtro00322	1
2044	Data de balanço 2	d_filtro00322	1
2045	Considerar Quebras	d_filtro0028	1
2046	Somente Produto Fidelizado Club DIA	d_filtro0028	1
2047	Informe o Tipo Situação Tributária (ICMS)	d_filtro00240	1
2048	Apresentar somente com desconto	d_filtro0028	1
2049	Cupons n?o Cancelados?	d_filtro0028	1
2073	Informe a Promoção	d_filtro_promocao	1
2076	Informe o Bairro do Produto	d_filtro00115	1
2104	Informe o Fabricante / Marca	d_filtro_marcafabricante	2
2105	Informe Número do Titulo ou Branco Para Todos	d_filtro00326	1
2106	Informe o Responsavel	d_filtro00115	1
2107	Código da Promoção(Separado por Virgula)	d_filtro00326	2
2108	Informe a senha do usuario do Vendedor	d_filtro_senha	10
2109	Informe a cidade a ser ignorada	d_filtro00116	1
4001	Informe a Meta 1	d_filtro00327	1
4002	Informe a Meta 2	d_filtro00327	1
4003	Informe a Meta 3	d_filtro00327	1
4401	Informe o número de Volume	d_filtro00326	2
5000	Informe o chamado	d_filtro00325	1
5001	Informe o Palete	d_filtro00326	1
5005	Informe o nº da planilha	d_filtro00326	1
5006	Bloqueia impressão de faturas de clientes inadimplentes	d_filtro00233	1
5432	Informe a Prateleira ou branco para todas	d_filtro00411	5
5455	Informe o lote ou branco para todos	d_filtro00115	1
7700	% Comissão Entrega Imediata	d_filtro00243	1
7701	% Comissão Entrega Normal	d_filtro00243	1
7702	Informe o valor da Despesa Bancária R$ 	d_filtro00243	1
7703	Informe o % de IR 	d_filtro00243	1
8001	Informe a situação dos cheques	d_filtro0032	1
8003	Produto inativo para compra	d_filtro00139	1
8004	Informe forma(s) de recebimento ou branco p/ todas	d_filtro0036	1
8888	Data/hora retirada inicial	d_filtro00140	1
8889	Data/hora retirada final	d_filtro00141	1
8890	Meta Inicial	d_filtro_qtdfim	2
8891	Data Inicial de Vendas	d_filtro00321	1
8892	Data Final de Vendas	d_filtro00322	1
8893	Data Inicial de Recebimento	d_filtro00321	1
8894	Data Final de Recebimento	d_filtro00322	1
9000	Informe o motorista ou branco para todos	d_filtro0013	2
9001	Quantidade Inicial - Sobra	d_filtro00327	1
9002	Quantidade Final - Sobra	d_filtro00327	1
9900	Informe o codigo da Coleta	d_filtro00115	4
9934	Informe a região	d_filtro00114	1
9991	Informe PAGAR ou RECEBER	d_filtro00115	1
9999	Informe o N° da Pré-Devolução	d_filtro000115	1
10000	Data/hora de movimento inicial b	d_filtro00140	1
10001	Data/hora de movimento final b	d_filtro00140	1
11149	Informe o Codigo do Balanco 1	d_filtro00115	2
11150	Informe o Codigo do Balanco 2	d_filtro00115	2
15000	Informe o banco	d_filtro00319	1
15001	Cobrador	d_filtro0036	1
15015	informe o socio ou branco pra todos	d_filtro0013	2
22214	Informe a senha do usu?rio do vendedor	d_filtro_senha	10
22215	Senha do vendedor	d_filtro_senha	8
50000	Somente produtos que permite estoque negativo	d_filtro0028	1
50001	Informe o grupo de conta contábil	d_filtro00323	1
50002	Mostrar produtos com saldo positivo	d_filtro0028	1
95000	Digite a placa no formato ABC1234 ou % para todos	d_filtro00115	1
99999	Informe o código do cliente	d_filtro00115	2
100000	Informe a faixa inicial	d_filtro00327	4
100001	Informe a faixa final	d_filtro00327	4
100017	Considerar Pontos Vencidos	d_filtro0028	1
100062	Informe a observação ou banco para todos	d_filtro00115	2
100142	Bloqueado (Inativo), Desbloqueado (Ativo), Ambos	d_filtro00139	1
100398	Digite o Código dos Clubes (separados por vírgula)	d_filtro00571	1
109000	Informe a 1a. conta contábil	d_filtro00133	1
109001	Informe a 2a. conta contábil	d_filtro00133	1
123456	Endereço de Entrega	d_filtro_endereco_entrega	1
125356	Informe a quantidade mínima	d_filtro_quant_minima_estoque	1
150000	Informe a quantidade mínima de giro	d_filtro00327	4
150001	Informe o nº nota venda	d_filtro00326	2
150002	Informe o nº nota remessa	d_filtro00326	2
150003	Informe o tipo de conta contabil	d_filtro00413	3
150004	Empresa(s) retirada ou branco para todos	d_filtro0031	6
150005	Empresa(s) origem ou branco para todos	d_filtro0031	2
150006	Informe a quantidade inicial	d_filtro00327	3
150007	Informe a quantidade final	d_filtro00327	5
150008	Informe a data final	d_filtro00238	2
150009	Informe o Número do Pedido	d_filtro00326	1
150010	Informe o(s) número(s) da nota(s) III	d_filtro00115	4
150011	informe o socio ou branco pra todos	d_filtro0013	2
150012	Percentual de Juros 	d_filtro00131	2
150013	Percentual Finaceiro	d_filtro00327	2
150014	Informe a margem inicial	d_filtro00327	2
150017	Data autorização inicial	d_filtro00321	2
150018	Data autorização final	d_filtro00322	3
150021	Informe a quantidade mínima de giro	d_filtro00327	4
150022	Informe as Cidades com virgula	d_filtro00326	1
150023	Informe o nº da autorização ou branco para todas	d_filtro00326	1
150024	Informe o % de juros	d_filtro00131	2
150025	Informe o item de modulo	d_filtro00444	2
150026	Informe a atividade	d_filtro00344	5
150027	Informe o Motorista	d_filtro00115	1
150028	Informe o Veiculo	d_filtro00115	1
150029	Informe o CPF/CNPF	d_filtro00115	1
150030	Informe o módulo do sistema ou branco para todos	d_filtro_modulos_comercializa	4
150031	Informe o meio de contato com ciss	d_filtro_meio_contato	2
150032	Informe a resposta desejada (qtd maquinas)	d_filtro_respostas_qtd_maquinas	5
150033	Meio de contato com a ciss ou branco para todos	d_filtro_todos_meios_contato	5
150034	Informe a Classe ou branco para todas	d_filtro_classe	2
150035	Informe o veículo	d_filtro00326	3
150036	Informe a data log inicial	d_filtro00321	2
150037	Informe a data log final	d_filtro00322	2
150038	Informe a data do ri inicial	d_filtro00321	3
150039	Informe a data do ri final	d_filtro00322	2
150040	Situação do relatório	d_filtro_situacao_relvisita	2
150041	Tipo da autorização (situação técnica)	d_filtro_tipoautorizacao	2
150042	Relatório de visita	d_filtro00326	2
150043	Informe o analista ou zero para todos	d_filtro0013	2
150044	Tipo de empresa	d_filtro_empresas_relvisita	2
150045	Ano	d_filtro00326	5
150046	Informe tipo cliente ou branco para todos	d_filtro_tipocliente	2
150047	Somente Clientes VIP	d_filtro0028	1
150048	Somente Clientes Negativo	d_filtro0028	1
150049	Listar Chamados Aguardando Atualização Versão	d_filtro0028	1
150050	Selecione o tipo do vendedor	d_filtro_tipovendedor	1
150051	Divisão tipo contrato	d_filtro_divisao_contrato	1
150052	Tipo de cliente ou branco para todos	d_filtro00115	1
150053	Lista clientes sem atendimento	d_filtro0028	2
150054	Informe o Concorrente	d_filtro0073	3
150055	Clientes sem atendimento	d_filtro0028	1
150056	Informe os Clientes	d_filtro0072	1
150057	Informe o tipo de Banco ou branco para todo	d_filtro00581	2
150058	Informe o tipo de valores de Itens de Módulo	d_filtro_item_modulos	2
150059	CISSMonitorKey instalado	d_filtro_condicao_instalacao_cmk	5
150060	Informe a marca/fabricante	d_filtro_marca	2
150099	Informe a(s) nota(as) de exceção	d_filtro00115	1
150102	Informe a(s) Empresa(s)ou branco para todos	d_filtro0031	
150112	Autorização	d_filtro00326	1
150123	Considerar produtos configurados como matéria-prima	d_filtro00233	1
150151	Selecione o tipo do contrato	d_filtro_tipocontrato	1
150152	N?vel 2	d_filtro00327	1
150153	N?vel 3	d_filtro00327	1
150154	N?vel 4	d_filtro00327	1
150164	Digite o(s) NCM(s) ou branco para todos	d_filtro00571	2
150196	Informe o(s) n°(s) da(s) nota(s)	d_filtro00452	1
150197	Informe o n° do(s) decreto(s)	d_filtro00452	1
150201	Somente produtos sem produ??o	d_filtro0028	1
150222	Informe o corredor ou branco p/ todos	d_filtro00115	3
150223	Informe o n? do m?s	d_filtro00326	1
150224	Mostrar somente produtos com diferen?a de custo	d_filtro00233	1
150225	Mostrar somente produtos com estoque negativo	d_filtro00233	1
150226	Informe o N.C.M. ou Branco para todos	d_filtro00115	1
150227	Informe a quantidade de produtos	d_filtro00327	1
150231	Situação Clientes	d_filtro_situacao_clientes	1
150232	Fase de Negociação	d_filtro_fasenegociacao	1
150233	Download, callcenter, ambas	d_filtrosituacaochave	1
150234	Material divulgação	d_filtro_materialdivulgacao	1
150235	Informe a pergunta desejada (qtd maquinas)	d_filtro_perguntas_qtd_maquinas	4
150236	Informe o motivo de não fechto venda	d_gerfil_motivo_naofectovenda	1
150300	Informe a área de alocação	d_filtro_area_alocacao	1
150301	Informe o nº da planilha da venda	d_filtro00326	1
150302	Informe o nº da planilha da carga	d_filtro00326	1
150303	Informe o nº da planilha do pedido	d_filtro00326	1
150322	Data final agendamento	d_filtro00322	1
150323	Data inicial agendamento	d_filtro00321	1
150324	Informe o Número do Concorrente	d_filtro00326	1
150325	Somante Produtos não enviados para o WMS	d_filtro00233	2
150326	Informe o número de cópias	d_filtro00289	1
150327	Mostrar Somente Produtos Com Diferença?	d_filtro00233	1
150500	Informe o estoque inicial	d_filtro00327	1
150501	Informe o estoque final	d_filtro00327	1
150502	Percentual de variação	d_filtro00256	2
150996	Informe o SGBD	d_filtro00585	1
150997	Somente pedidos pendentes de faturamento	d_filtro0028	1
150998	Informe o SGBD	d_filtro_sgbd	1
150999	Informe o valor do frete	d_filtro0241	1
151023	Informe a quantidade a listar	d_filtro00289	1
159990	Informe o Valor Inicial de Limite	d_filtro00327	1
159991	Informe o Valor Final de Limite	d_filtro00327	1
160000	Informe a quantidade mínima de giro	d_filtro00327	4
160093	Exibe títulos agrupados	d_filtro_agrupados	2
160160	Informe a 1ª empresa	d_filtro0031	1
160161	Informe a 2ª empresa	d_filtro0031	1
160162	Informe a Divisão	d_filtro00561	1
160163	Informe a seção	d_filtro00212	1
160177	Informe o tipo de conta contabil	d_filtro00413	3
160178	Informe o Número do cheque	d_filtro00326	1
160179	Informe o Número do Título ou branco para todos	d_filtro00326	1
160182	Informe o nº nota venda	d_filtro00326	2
160250	Informe o tipo de conta contabil	d_filtro00413	3
160341	Informe o nº nota venda	d_filtro00326	2
160365	Informe a quantidade mínima de giro	d_filtro00327	4
200062	Informe a observação ou banco para todos	d_filtro00115	2
200063	Informe o Número de Dias para Sugestão	d_filtro00326	1
200064	Empresa(s) retirada ou branco para todos	d_filtro0031	1
200065	Informe as divisões ou branco para todas	d_filtro00333	2
200189	informe o socio ou branco pra todos	d_filtro0013	2
250003	Informe o local de estoque principal	d_filtro00575	1
250004	Informe a empresa do estoque principal	d_filtro0061	1
250005	Informe o porcentual (Gatilho)	d_filtro00131	1
300000	Informe a(s) empresa(s) saldo de estoque	d_filtro00326	1
300001	Informe as Seções	d_filtro0031	1
300002	Somente cadastros alterados	d_filtro0028	1
330001	Digite a observação 1	d_filtro00571	1
330002	Digite a observação 2	d_filtro00571	1
330003	Digite a observação 3	d_filtro00571	1
330004	Digite a observação 4	d_filtro00571	1
330005	Duplicata (sim), cheque (não)	d_filtro0028	1
333001	Informe os Títulos	d_filtro00326	1
555666	Mostrar Produtos Sem Parametros	d_filtro00233	1
777880	Informe o produto ou branco para todos	d_filtro0561	2
878787	Tipo Situação Pis/Cofins	d_filtro_situacao_piscofins	1
999922	Informe o código da promoção ou branco para todos	d_filtro00326	1
999998	Informe o(s) NCM(s)	d_filtro_ncm	1
999999	Informe o ncm	d_filtro00115	1
1150186	Data de validade final	d_filtro00322	1
1500015	Informe o tipo de conta contabil	d_filtro00413	3
1500025	Informe o tipo de conta contabil	d_filtro00413	3
1500032	(Sim) Para Movimento (Não) Para Vencimento	d_filtro00233	1
1500041	Informe o avalista	d_filtro0013	1
1500042	Informe o segundo avalista	d_filtro0013	1
1500051	Nome de entrega ou brancos para todos	d_filtro00115	1
1500129	MARQUE X	d_filtro00115	2
1500148	Informe a descrição do produto	d_filtro00115	1
1500149	Marque x	d_filtro00115	2
1500150	Informe o numero adiantamento	d_filtro00326	4
1500151	Não Utilizar (ERRO)	d_filtro00326	4
1500159	MARQUE X	d_filtro00115	2
1500169	MARQUE X	d_filtro00115	2
1500179	MARQUE X	d_filtro00115	2
1500189	MARQUE X	d_filtro00115	2
1500199	MARQUE X	d_filtro00115	2
1500209	MARQUE X	d_filtro00115	2
1500210	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500211	Não Utilizar (ERRO)	d_filtro00326	4
1500219	Informe o nº da autorização ou branco para todas	d_filtro00326	1
1500229	Informe o nº da autorização ou branco para todas	d_filtro00326	1
1500320	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500329	Informe o nº da autorização ou branco para todas	d_filtro00326	1
1500359	Informe o nº da autorização ou branco para todas	d_filtro00326	1
1500379	MARQUE X	d_filtro00115	2
1500410	Informe o numero adiantamento	d_filtro00326	4
1500411	Não utilizar (erro)	d_filtro00326	4
1500419	Informe o nº da autorização ou branco para todas	d_filtro00326	1
1500449	MARQUE X	d_filtro00115	2
1500480	Informe o numero adiantamento	d_filtro00326	4
1500481	Não utilizar (erro)	d_filtro00326	4
1500489	Informe o nº da autorização ou branco para todas	d_filtro00326	1
1500519	MARQUE X	d_filtro00115	2
1500529	MARQUE X	d_filtro00115	2
1500590	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500609	MARQUE X	d_filtro00115	2
1500619	Marque x	d_filtro00115	2
1500621	Informe a situação do(s) título(s)	d_filtro00148	1
1500631	Informe a situação do(s) título(s)	d_filtro00148	1
1500640	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500641	Não Utilizar (ERRO)	d_filtro00326	4
1500651	Informe a situação do(s) título(s)	d_filtro00148	1
1500671	Informe a situação do(s) título(s)	d_filtro00148	1
1500680	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500681	Não Utilizar (ERRO)	d_filtro00326	4
1500699	Marque x	d_filtro00115	2
1500709	MARQUE X	d_filtro00115	2
1500730	Informe o numero adiantamento	d_filtro00326	4
1500731	Não utilizar (erro)	d_filtro00326	4
1500749	MARQUE X	d_filtro00115	2
1500750	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500751	Não Utilizar (ERRO)	d_filtro00326	4
1500779	MARQUE X	d_filtro00115	2
1500789	Marque x	d_filtro00115	2
1500875	Informe o tipo de conta contabil	d_filtro00413	3
1500879	MARQUE X	d_filtro00115	2
1500899	MARQUE X	d_filtro00115	2
1500910	Informe o numero adiantamento	d_filtro00326	4
1500949	Marque x	d_filtro00115	2
1500950	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500960	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500969	Marque x	d_filtro00115	2
1500989	Marque x	d_filtro00115	2
1500990	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1500999	Marque x	d_filtro00115	2
1501030	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1501089	MARQUE X	d_filtro00115	2
1501099	MARQUE X	d_filtro00115	2
1501109	MARQUE X	d_filtro00115	2
1501119	MARQUE X	d_filtro00115	2
1501129	MARQUE X	d_filtro00115	2
1501139	MARQUE X	d_filtro00115	2
1501205	Informe o tipo de conta contabil	d_filtro00413	3
1501380	INFORME O NUMERO ADIANTAMENTO	d_filtro00326	4
1501381	Não Utilizar (ERRO)	d_filtro00326	4
1501629	MARQUE X	d_filtro00115	2
1501639	MARQUE X	d_filtro00115	2
1501729	MARQUE X	d_filtro00115	2
1501895	Informe o tipo de conta contabil	d_filtro00413	3
1501905	Informe o tipo de conta contabil	d_filtro00413	3
1501961	Informe a situação do(s) título(s)	d_filtro00148	1
1502010	Informe o numero adiantamento	d_filtro00326	4
1502282	Informe o código suframa	d_filtro0011150228	4
1503069	MARQUE X	d_filtro00115	2
1503302	Informe o código suframa	d_filtro0011150330	4
1506009	Marque x	d_filtro00115	2
1507119	Marque x	d_filtro00115	2
1507129	Marque x	d_filtro00115	2
1508005	Informe o tipo de conta contabil	d_filtro00413	3
1509009	MARQUE X	d_filtro00115	2
1510009	MARQUE X	d_filtro00115	2
1510149	Marque x	d_filtro00115	2
1510159	Marque x	d_filtro00115	2
1510179	Marque x	d_filtro00115	2
1510189	Marque x	d_filtro00115	2
1510320	Informe o numero adiantamento	d_filtro00326	4
1510329	Informe o nº da autorização ou branco para todas	d_filtro00326	1
1550999	Marque x	d_filtro00115	2
1551199	MARQUE X	d_filtro00115	2
1551219	MARQUE X	d_filtro00115	2
1551729	MARQUE X	d_filtro00115	2
1552729	MARQUE X	d_filtro00115	2
1556009	Marque x	d_filtro00115	2
1556010	Somente Produto Com Saldo no Central ?	d_filtro0028	5
1556011	Informe o numero de dias de Cobertura	d_filtro00289	1
1556012	Informe o Gerente\Subgerente da Liberação	d_filtro00430	1
1556013	Informe o numero do NFC-E	d_filtro00326	2
1556014	Informe a categoria ou branco para todos 	d_filtro00115	1
1556015	Informe o colaborador ou branco para todos 	d_filtro0013	1
1556016	Valor do Adiantamento Maior que	d_filtro00131	2
1556017	Informe a modalidade da bonificacao	d_filtro00326	2
1556018	Minutos de Intervalo de Vendas	d_filtro00326	3
1556019	Informe Código da Agenda	d_filtro00326	1
1800189	Marque x	d_filtro00115	2
1800190	A PRAZO - 2 	d_filtro00233	1
1800191	Convênio - 7 	d_filtro00233	1
1800192	Columbia Card - 40 	d_filtro00233	1
1800193	Cheque a vista - 16 	d_filtro00233	1
1800194	Cheque a prazo - 9 	d_filtro00233	1
2000092	Vencimento Impresso	d_filtro00321	1
2000093	EmissÃ£o Impresso	d_filtro00322	1
4150228	Informe o bairro ou branco para todos 	d_filtro0011150228	1
4150330	Informe o bairro ou branco para todos 	d_filtro0011150330	1
8888801	Informe a empresa de Venda	d_filtro0031	1
8888802	Informe a empresa de Estoque	d_filtro0031	1
8888888	Informe P=Pendente, R=Parcial, C=Concluído ou Branco p/ todos	d_filtro00115	3
9899984	Informe a data de vencimento do convenio	d_filtro00322	2
9998789	Informe a Quantidade de Meses	d_filtro00115	1
9999915	Apresentar Produtos	d_filtro00233	1
9999916	(FRE)frente caixa (Branco) para todos	d_filtro00115	4
9999917	Data vencimento Produto	d_filtro00322	2
9999918	(SIM) Para todos (Não) somente frente de caixa	d_filtro00233	1
9999919	AVAL CASO TENHA	d_filtro0013	1
9999920	QTD PARCELAS PARA COMPRAS	d_filtro00326	3
9999921	Dia promoção especial mercado	d_filtro00233	1
9999922	MOTIVO PARCELAMENTO	d_filtro00115	4
9999923	(Sim)Ver intenção relatorio(Não)Liberação atendimento	d_filtro00233	1
9999924	PLANILHA de origem **(ver obs)	d_filtro00326	1
9999925	Data movimento final agrupamento	d_filtro00322	1
9999926	Data movimento inicial agrupamento	d_filtro00321	1
9999927	META	d_filtro00327	1
9999928	4 ULTIMOS digitos do ncm	d_filtro00326	1
9999929	4 PRIMEIROS digitos do ncm POSICAO	d_filtro00326	1
9999930	N° do pedido ou branco s/ pedido	d_filtro00326	2
9999931	NOVO VALOR	d_filtro00327	1
9999932	Fornecedor Para Transferencia	d_filtro0013	1
9999933	Forma de pagamento	d_filtro0036	1
9999934	Informe a atividade	d_filtro00115	1
9999935	Valor	d_filtro00327	1
9999936	Nota 9	d_filtro00326	1
9999937	Nota 8	d_filtro00326	1
9999938	Subproduto kit ou branco para todos	d_filtro0561	6
9999939	Produto kit ou branco para todos	d_filtro0023	1
9999940	(sim)para todos (não)somente pos	d_filtro00233	1
9999941	Quem recebeu	d_filtro0013	1
9999942	Quem pagou	d_filtro0013	1
9999943	Referente ou motivo pagamento 3	d_filtro00115	4
9999944	Referente ou motivo pagamento 2	d_filtro00115	4
9999945	Referente ou motivo pagamento 1	d_filtro00115	4
9999946	Valor dos boletos	d_filtro00327	1
9999947	Movimento final ch. vista	d_filtro00322	1
9999948	Vencimento final ch. vista	d_filtro00322	1
9999949	Data movimento cheque liq/ reapresentado	d_filtro00322	2
9999950	Nota 7	d_filtro00326	1
9999951	Nota 6	d_filtro00326	1
9999952	Nota 5	d_filtro00326	1
9999953	Nota 4	d_filtro00326	1
9999954	Nota 3	d_filtro00326	1
9999955	Nota 2	d_filtro00326	1
9999956	Nota 1	d_filtro00326	1
9999957	Porcentagem menor ou igual	d_filtro00326	3
9999958	Porcentagem maior ou igual	d_filtro00326	3
9999959	Estoque atual menor que	d_filtro00326	3
9999960	Estoque atual maior que	d_filtro00326	3
9999961	Média venda mes maior que	d_filtro00289	1
9999962	N° de dias s/ vendas	d_filtro00289	1
9999963	Numero da promoção	d_filtro00326	2
9999964	Mostrar somente passo 4	d_filtro00233	1
9999965	Mostrar ja cobrados	d_filtro00233	1
9999966	Mostrar produtos sem acordo	d_filtro00233	1
9999967	Entrada 2	d_filtro00115	4
9999968	Saida 2	d_filtro00115	4
9999969	Saida 1	d_filtro00115	4
9999970	Entrada 1	d_filtro00115	4
9999971	Mostrar titulos bloqueados	d_filtro00233	1
9999972	N° nota devolução	d_filtro00326	2
9999973	N° nota compra	d_filtro00326	2
9999974	Mostrar somente pendentes	d_filtro00233	1
9999975	Mostrar clientes com titulos em aberto	d_filtro00233	1
9999976	Pedido de isenção taxa	d_filtro00233	1
9999977	Valor comprado avulso	d_filtro00327	1
9999978	Km s distancia ida	d_filtro00326	1
9999979	Cupom 5	d_filtro00326	1
9999980	Cupom 4	d_filtro00326	1
9999981	Cupom 3	d_filtro00326	1
9999982	Cupom 2	d_filtro00326	1
9999983	Cupom 1	d_filtro00326	1
9999984	Infome o novo dia para vencimento	d_filtro00326	2
9999985	Numero telefone com ddd	d_filtro00115	4
9999986	Nome do prêmio	d_filtro00115	4
9999987	Numero da opção	d_filtro00326	2
9999988	Hora final	d_filtro00115	4
9999989	Hora incial	d_filtro00115	4
9999990	Vencimento cartão	d_filtro00322	1
9999991	CODIGO DO COMPRADOR PARA AVALISTA	d_filtro00115	4
9999992	DIGITO DO TITULO	d_filtro00326	1
9999993	MOTIVO DO MOVIMENTO	d_filtro00115	4
9999994	ESCREVER NOME DO ESPAÇO	d_filtro00115	4
9999995	VALOR COMBINADO	d_filtro00327	1
9999996	CODIGO LANCAMENTO DO BRINDE	d_filtro00326	1
9999997	INFORME O CODIGO DO DEPENDENTE	d_filtro00326	1
9999998	INFORME O CONVENIADO	d_filtro0013	1
9999999	INFOME O CONVENIO	d_filtro0013	1
15211601	Informe a Difrença	d_filtro00326	1
99912345	Informe o(s) Subproduto(s)	d_filtro0561	1
99999897	Sim - Card/prazo/ch. Não - Convenio	d_filtro00233	1
99999898	Mostrar produtos c/cotação e ja pedidos	d_filtro00233	1
99999899	Informe a(s) empresa(s).	d_filtro0031	1
99999999	Infomrme o CPF OU CNPJ do Dono 	d_filtro00115	3
121212001	Listar somente Produtos Inativos para Compra?	d_filtro0028	1
121212002	Informe a Pontuação por Vendas	d_filtro00327	1
121212003	Informe a Pontuação por Quantidade	d_filtro00327	1
121212004	Informe os Locais de Retirada (Separe por vírgula)	d_filtro00115	1
121212005	Informe a(s) Região(ões) (Separe por vírgula)	d_filtro00115	1
121212006	Infome o local de entrega ou branco para todos	d_filtro00326	1
121212007	Informe o(s) CFOP(s) separados por vírgula.	d_filtro00115	1
121212008	Data de emissão inicial TESTE	d_filtro00321	1
121212009	Data de emissão final TESTE	d_filtro00322	1
121212010	Data de vencimento inicial TESTE	d_filtro00321	1
121212012	Selecione o tipo de pedido	d_filtro001001	1
121212013	Informe o serviço ou branco para todos	d_filtro000117	1
121212014	Informe o Bairro do Produto	d_filtro00540	1
121212015	Informe o Tipo Natureza	d_filtro00790	1
121212016	"""Informe a marca/fabricante"	d_filtro_marca	1
121212017	Informe o n° do Documento ou branco para todos	d_filtro00326	1
121212018	Informe a Rua do Produto	d_filtro00115	1
121212019	Informe o Bloco do Produto	d_filtro00115	1
121212020	Informe o Nível do Produto	d_filtro00115	1
789123123	Somente produtos com Venda 	d_filtro00139	1
789123124	Informe a Situação do Código CEST	d_filtro000120	1
999911111	Informe o Custo do M³	d_filtro00327	1
999911112	Informe o Contador Reserva	d_filtro00326	1
999911113	Informe o(s) Número(s) Sequencia(is)	d_filtro00115	1
999911114	Informe o número de dias para cálculo	d_filtro00326	1
999911115	Informe as contas contábeis de crédito	d_filtro00439	1
999911117	Informe o Tipo da Operação	d_filtro000122	1
999911118	Informe o nome (não login) ou % para todos	d_filtro00411	5
999911119	Apresentar Movimentação Geral	d_filtro00233	1
||||||||||1	PASTTAB E PASTFIL NÃO EXPORTADOS 14.0
||||||||||150600	160	RA_IDEMPRESA	=	1	T	F
150600	427	RA_IDLOCALESTOQUE	=	2	T	F
150600	36	RA_IDGRUPO	=	3	T	F
150600	35	RA_IDSUBGRUPO	=	4	T	F
150600	37	RA_IDSECAO	=	5	T	F
150600	67	RA_IDSUBPRODUTO	=	6	T	F
150600	129	RA_DTINI	=	7	T	F
150600	130	RA_DTFIM	=	8	T	F
||||||||||7	19	Movimentação de Estoque	Movimentação de Estoque
||||||||||	TABELAS NÃO EXPORTADAS 14.0	
||||||||||