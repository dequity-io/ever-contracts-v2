INC_PATH += include
#include ctx.mk
#VAR:=var
#LIB:=$(VAR)/lib
#LOG:=$(VAR)/log
#CACHE:=$(VAR)/cache
#SNAP:=$(VAR)/snap
#TMP:=$(VAR)/tmp
#CADDR:=$(CACHE)/address
#CCONF:=$(CACHE)/ctxconfig
#CTX:=$Q
#PID:=2e786c9575af406fa784085c88b5e7e3
#AK:=38f728004a4b40e2a8aa30f8fee45346

#include bak/files.mk2
include files
CTX:=$Q
include ../common.mk

define _page
$(call $2,$(wordlist 1,50,$1))
$(eval tail:=$(wordlist 51,$(words $1),$1))
$(if $(tail),$(call _page,$(tail),$2))
endef

define _pageto
$(call $2,$(wordlist 1,50,$1)) >>$3
$(eval tail:=$(wordlist 51,$(words $1),$1))
$(if $(tail),$(call _pageto,$(tail),$2,$3))
endef

$(BLD)/%.abi.json: %.sol
	$(SOLD) $< --base-path . $(foreach i,$(INC_PATH),-i $i) --abi-json -o $(BLD)

#RROOTS:=$(patsubst %,%$R,$(RDIRS))
#COX:=$B $B$R $D$W $I $(IB) $P $P$R $T$R $T $U $U$R $S $S$R $F $F$R $W
#include gg.mk
#PRN?=3
A=jq -r '.config.addr' $(ETC)/
WN = 0 1 2
PRN = 3
UN3 = 0 1 2 3 4 5 6 7 8 9
UL?=$(UN$(PRN))
RN=$(PRN)
RL=$(UL)
AD?=$(ETC)/Y$(PRN)
PN = 0 1 2 3
MWN?=2
#UL?=$(UN$(PRN))
#$(BLD)/$Q.tvc: $(BLD)/$B.tvc
#$(BLD)/$Q.tvc: $(patsubst %,$(BLD)/%.tvc,$(COX))
#	@true
#AD?=$(ETC)/Y$(PRN)
#-include g1.mk
z=$(TOC) -c $(ETC)/$Q.conf callx -m test --n $1 --k $2
#J=$(TOC) -c $(ETC)/$Q.conf runx -m $@ | jq -r .out
#-include g2.mk
d: $(patsubst %,$(BLD)/%.cs,$(COX))
	$(foreach a,$(shell seq 1 16),$(TOC) -c $(ETC)/$Q.conf callx -m add --n $a --name $(word $a,$(COX)) --c `cat $(word $a,$^)`;)
u: $(patsubst %,$(BLD)/%.cs,$(COX))
	$(foreach a,$(shell seq 1 16),$(TOC) -c $(ETC)/$Q.conf callx -m update --n $a --c `cat $(word $a,$^)`;)
snd:
	$(TOC) -c $(ETC)/$Q.conf callx -m send --dest `$AX$(to)/$W` --value $(val)

v:
	$(MAKE) -f cnf.mk vi

s:
	$(MAKE) -f cnf.mk show
nou?=10
ggf:
	$(TOC) -c $(ETC)/$P$R runx -m getGasFee --answerId 1 --numOfUnits $(nou) | jq -r .mintGasFee

#tpm: ; $(TOC) -c $(ETC)/$Q.conf callx -m act --op 6 --src 1 --dst 2 --val 100 --fee 165100000000
tpm: ; $(TOC) -c $(ETC)/$Q.conf callx -m act --op 6 --src 1 --dst 2 --val 10 --fee 211
tpm2: ; $(TOC) -c $(ETC)/$Q.conf callx -m act --op 6 --src 1 --dst 2 --val 5 --fee 131
3?=
4?=
k?=0
test scen:
	$(TOC) -c $(ETC)/$Q.conf callx -m $@ --n $n --k $k

test001: ;	$(call z,1,2)
test002:
	$(call z,2,1)
	$(call z,2,2)

_gg1=$(foreach f,$1,printf "%s:\n" $f;$(foreach j,$(filter-out %Code,$(G_$f)),printf "\t%s: " $j;$($f.$j);))
_gg2=$(foreach a,$(value $2),printf "%s:\n" $a;$(foreach f,$3,printf "%s:\n" $f;$(foreach j,$($1_$f),printf "\t%s: " $j;$($f.$j$a);)))
_gg3=$(foreach a,$(value $2),printf "%s:" $a;$(foreach f,$3,printf "%s:\n" $f;$(foreach j,$($1_$f),printf "%s:\n" $j;$(foreach i,$($4),printf "\t%s%s: " $f $i;$($f$i.$j$a);))))

SCOPE=$(patsubst %,X%/$W,$(WN)) $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T)
ex1: $(patsubst %,$(ETC)/X%/$W,$(WN)) $(patsubst %,$(ETC)/%,$(RROOTS))
	$(foreach a,$^,printf "%s %s\t" $(notdir $a) $(dir $a):; $(TOC) -c $a account | jq -r .balance;)
_ex=$(foreach a,$1,$(TOC) -c $a account | jq -r .balance >>$2;)
mex:
	rm -f ex ex7
	$(call _ex,$(addprefix $(ETC)/,$(SCOPE)),ex7)
	cat ex7 | tr -d ' ' >ex
	$(call _sum,ex)
ex: $(addprefix $(ETC)/,$(SCOPE))
	echo $^ >ll
	$(foreach a,$^,$(TOC) -c $a account | jq -r .balance >>$@;)
	$(call _sum,$@)
SC2=$(patsubst %,$(AD)/%/$T,$(shell seq 0 99))
SC3=$(wildcard $(patsubst %,$(AD)/%/,$(shell seq 0 99)))
SC4=$(wildcard $(AD)/*/*)
S099:=$(shell seq 0 555)
TOC67:=~/bin/0.67/tonos-cli
_a=jq -r .config.addr $1
_ab=jq -r .config.addr $1 | xargs echo | xargs $(TOC67) account | jq -rs '.[] | map_values(.balance?)[]' >>$@
_ab0=jq -r .config.addr $1 | xargs echo | xargs $(TOC67) account | jq -rs '.[] | map_values(.balance?)[]'
_ac=echo $1
_sum=paste $1 -sd+ | bc
_sum2=paste $1 -sd+ | tr ' ' + | bc
_sum3=paste $1 -sd+ | tr '\t' + | xargs printf "scale=3;(%s) / 1000000000\n" | bc | xargs printf "%.03g\n"
px:
	$(call _page,$(S099),_ac)
mbx:
	$(call _pageto,$(SC4),_ab0,bx7)
	$(call _sum,bx7)
mx:
	rm -f ex7 ex bx7
	$(call _ex,$(addprefix $(ETC)/,$(SCOPE)),ex7)
	cat ex7 | tr -d ' ' >ex
	$(eval of!=date +%s)
	$(call _sum,ex) >$(of)
	$(call _pageto,$(SC4),_ab0,bx7)
	$(call _sum,bx7) >>$(of)
	cat $(of)
HX?=1703327769
#HB=$(HX)
HB=1703425827

np00:
	echo AD: $(AD) UL: $(UL)
np0:
	mkdir -p $(AD)
	$(foreach a,$P $U$R $D$W $D$W$T $(IB),cp $(ETC)/$a $(AD);)
	$(TOC) -c $(ETC)/$P$R runx -m nftAddress --answerId 1 --id $(PRN) | jq -r .nft | xargs $(TOC) -c $(AD)/$P config --addr
	$(TOC) -c $(AD)/$P runx -m getUnitRoot --answerId 1 --id $(PRN) | jq -r .unitRoot | xargs $(TOC) -c $(AD)/$U$R config --addr
	$(TOC) -c $(AD)/$P runx -m getDistrWallet --answerId 1 --id $(PRN) | jq -r .distrWallet | xargs $(TOC) -c $(AD)/$D$W config --addr
	$(TOC) -c $(AD)/$U$R runx -m resolveIndexBasis --answerId 1 | jq -r .indexBasis | xargs $(TOC) -c $(AD)/$(IB) config --addr
	$(TOC) -c $(ETC)/$T$R runx -m walletOf --answerId 1 --walletOwner `$AY$(PRN)/$D$W` | jq -r .value0 | xargs $(TOC) -c $(AD)/$D$W$T config --addr
AZ:=0:0000000000000000000000000000000000000000000000000000000000000000
np1:
	$(TOC) -c $(AD)/$U$R runx -m totalSupply --answerId 1 | jq -rc '.count | tonumber | range(0,.)' | xargs echo
	$(foreach i,$(UL),mkdir -p $(AD)/$i;$(foreach f,$U $S $T $I $I0,cp $(ETC)/$f $(AD)/$i;))
	$(foreach i,$(UL),$(TOC) -c $(AD)/$U$R runx -m nftAddress --answerId 1 --id $i | jq -r .nft | xargs $(TOC) -c $(AD)/$i/$U config --addr;)
	$(foreach i,$(UL),$(TOC) -c $(ETC)/$S$R runx -m sellAddress --answerId 1 --unit `$AY$(PRN)/$i/$U` | jq -r .value0 | xargs $(TOC) -c $(AD)/$i/$S config --addr;)
	$(foreach i,$(UL),$(TOC) -c $(ETC)/$T$R runx -m walletOf --answerId 1 --walletOwner `$AY$(PRN)/$i/$S` | jq -r .value0 | xargs $(TOC) -c $(AD)/$i/$T config --addr;)
np2:
	$(eval owner!=$(TOC) -c $(AD)/$P runx -m getInfo --answerId 1 | jq -r .owner)
	$(eval collection!=$(TOC) -c $(AD)/$(IB) runx -m getInfo --answerId 1 | jq -r .collection)
	$(foreach i,$(UL),$(TOC) -c $(AD)/$i/$U runx -m resolveIndex --answerId 1 --collection $(AZ) --owner $(owner) | jq -r .index | xargs $(TOC) -c $(AD)/$i/$I0 config --addr; $(TOC) -c $(AD)/$i/$U runx -m resolveIndex --answerId 1 --collection $(collection) --owner $(owner) | jq -r .index | xargs $(TOC) -c $(AD)/$i/$I config --addr;)	
mr30:
	$(eval of!=date +%s)
	rm -f ex7 ex8 bx7
	$(call _ex,$(addprefix $(ETC)/,X1/$W X2/$W $(RROOTS)),ex7)
	cat ex7 | tr -d ' ' >ex8
	$(call _sum,ex8) >$(of)
	cat $(of)
mr31:
	$(eval of!=date +%s)
	rm -f ex8 bx7
	$(call _ex,$(addprefix $(ETC)/,$(patsubst %,Y$(PRN)/%,$P $U$R $D$W $(IB) $D$W$T)),ex8)
	$(call _sum,ex8) >$(of)
	cat $(of)
mr32:
	$(eval of!=date +%s)
	rm -f ex8 bx7
	$(call _pageto,$(SC4),_ab0,bx7)
	$(call _sum,bx7) >>$(of)
	cat $(of)

#m top OP=Sell
#m top OP=Cancel
MGR?=2
RCP?=0
OP?=Sell
DEST?=$(MGR)/$B
Sell_U=U
Cancel_U=S
Buy_U=S
Withdraw_U=U
_Sell=--usr `$A$S$R` --prices `echo $(UL) | jq -sc '[.[] | 1000000000 + .]'`
_Cancel=
bp:
	$(foreach a,$(patsubst %,$(ETC)/Y$(PRN)/%/$S,$(UL)),$(TOC) -c $a runx -m getOfferInfo --answerId 1 | jq -r .price >>$@;)
_Buy=--amount `cat bp | jq -cs 'add'` --recipient `$AX$(RCP)/$B` --remainingGasTo `$AX$(RCP)/$W` --prices `cat bp | jq -cs '.'`
_Withdraw=--amounts `echo $(UL) | jq -sc '[.]'`
_withdrawval=$(TOC) -c $(ETC)/X$(MGR)/$B runx -m getWithdrawDisrtibutedTokensGasFee --answerId 1 --amount $(words $(UL)) | jq -r '.withdrawGasFee | tonumber | . / 100000000 | . += 10'
twith:
	$(TOC) -c $(ETC)/$Q.conf runx -m encodeBulk$(OP) --contracts `jq -cs '[.[].config.addr]' $(patsubst %,$(ETC)/Y$(PRN)/%/$($($(OP)_U)),$(UL))` $(_Withdraw) | jq -r .c | xargs $(TOC) -c $(ETC)/X$(MGR)/$W callx -m send --dest `$AX$(DEST)` --value `$(_withdrawval)` --payload
top:
	$(TOC) -c $(ETC)/$Q.conf runx -m encodeBulk$(OP) --contracts `jq -cs '[.[].config.addr]' $(patsubst %,$(ETC)/Y$(PRN)/%/$($($(OP)_U)),$(UL))` $(_$(OP)) | jq -r .c | xargs $(TOC) -c $(ETC)/X$(MGR)/$W callx -m send --dest `$AX$(DEST)` --value `$(TOC) -c $(ETC)/X$(MGR)/$B runx -m getBulk$(OP)GasFee --answerId 1 --amount $(words $(UL)) | jq -r '.total$(OP)GasFee | tonumber | . / 100000000 | . += 3'` --payload
tbp:
	$(eval contracts!=jq -cs '[.[].config.addr]' $(patsubst %,$(ETC)/Y$(PRN)/%/$($($(OP)_U)),$(UL)))
	$(eval nprices!=cat bp)
	$(eval totalPrice!=echo $(nprices) | jq -cs 'add')
	$(eval prices!=echo $(nprices) | jq -cs '.')
	echo contracts: $(contracts) nprices: $(nprices) totalPrice: $(totalPrice) prices: $(prices)
	$(eval payload!=$(TOC) -c $(ETC)/$Q.conf runx -m encodeBulkBuy --contracts $(contracts) --amount $(totalPrice) --recipient `$AX0/$B` --remainingGasTo `$AX0/$W` --prices $(prices) | jq -r .c)
	echo $(payload)
	$(eval value!=$(TOC) -c $(ETC)/X$(MGR)/$B runx -m getBulk$(OP)GasFee --answerId 1 --amount $(words $(UL)) | jq -r '.total$(OP)GasFee | tonumber | . / 100000000 | . += 3')
	echo V $(value)
	$(TOC) -c $(ETC)/X$(MGR)/$W callx -m send --dest `$AX$(RCP)/$T` --value $(value) --payload $(payload)

#_msum=
msu_%: %/root %/system %/unit
	$(foreach a,$^,$(call _sum,$a);)
mba_%: %
#	echo $*
	$(foreach a,$(wildcard $*/b_*),$(call _sum,$a);)
#MWN=0
$(HB)/%.bY$(PRN):
	$(call _pageto,$(wildcard $(AD)/*/$*),_ab0,$@)
$(HB)/%$R.b: $(ETC)/%$R
	$(TOC) -c $< account | jq -r .balance >$@
$(HB)/%.b$(PRN): $(ETC)/Y$(PRN)/%
	$(TOC) -c $< account | jq -r .balance >$@
$(HB)/%.bX$(MWN): $(ETC)/X$(MWN)/%
	$(TOC) -c $< account | jq -r .balance | tr -d ' ' >$@

HBB?=$(shell date +%s)
mb:
	mkdir -p $(HBB)
	$(MAKE) HB=$(HBB) $(HBB)/msb
	cat $(HBB)/msb
ms:
	$(MAKE) $(HX)/msp
	$(call _cmp,$(HX)/msb $(HX)/msp)

aa?=balance
DA0=$Q.conf
DA1=X0/$W X1/$W X2/$W
DA2=X2/$W $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T $(IB))
D0=$(patsubst %,Y$(PRN)/%/,$(UL))
DA3=$(addsuffix $U,$(D0)) $(addsuffix $I,$(D0)) $(addsuffix $I0,$(D0))
DA4=$(DA3) $(addsuffix $S,$(D0)) $(addsuffix $T,$(D0))
al?=2
$(VCCONF)/roster.ctx:
	$(foreach a,$(shell seq 1 16),printf "%d\t%s\n" $a $(word $a,$(COX)) >>$@;)
define t-confg
	rm -f $(VCCONF)/$1.ctx
	printf "%s\t%s\n" $1 "$2" >>$(VCCONF)/$1.ctx
endef

ge2:
	$(MAKE) -f conf0.mk


#	$(TOC) -c $(ETC)/$Q.conf callx -m update --n $a --c `cat $(word $a,$^)`;)
#$(CCONF)/$R.cxl: 
cadd: $(patsubst %,$(VCADDR)/da%,0 1 2 3 4)
caddl: $(patsubst %,$(VCADDR)/adl%,0 1 2 3 4)
cdma:# $(wildcard $(ETC)/X*)
	$(foreach a,$(WN),mkdir -p $(VCADDR)/X$a;)
	$(foreach a,$(PN),$(foreach i,$(UN$a),mkdir -p $(VCADDR)/Y$a/$i;))

cdla: $(patsubst %,$(VCADDR)/X%.adl,$(WN)) $(patsubst %,$(VCADDR)/Y%.adl,$(PN))
#	$(foreach a,$(WN),mkdir -p $(CADDR)/X$a;)
#	$(foreach a,$(PN),$(foreach i,$(UN$a),mkdir -p $(CADDR)/Y$a/$i;))
cda: $(patsubst %,$(VCADDR)/%.da,$(DA0) $(DA1) $(DA2) $(DA3) $(DA4))
#$(CADDR)/da%: $(patsubst %,$(ETC)/%,$(DA$%))
#$(CADDR)/%.bY$(PRN):
#	$(call _pageto,$(wildcard $(AD)/*/$*),_ab0,$@)
$(VCADDR)/%.da: $(ETC)/%
	jq -r .config.addr $< >$@
$(VCADDR)/%.adl:
#	$(foreach a,$(wildcard $(ETC)/$*/*),echo $a;)
	rm -f $@
	$(foreach a,$(wildcard $(ETC)/$*/*),jq -r .config.addr $a | xargs printf "%s\t%s\n" $(notdir $a) >>$@;)
#	jq -r .config.addr $< | xargs printf "%s\t%s\n" $* >>$@
#$(CADDR)/%$R.da: $(ETC)/%$R
#	jq -r .config.addr $< >$@
#	$(TOC) -c $< account | jq -r .balance >$@
#$(CADDR)/%.Y$(PRN).da: $(ETC)/Y$(PRN)/%
#	jq -r .config.addr $< >$@
#	$(TOC) -c $< account | jq -r .balance >$@
#$(CADDR)/%.X$(MWN).da: $(ETC)/X$(MWN)/%
#	jq -r .config.addr $< >$@
#	$(TOC) -c $< account | jq -r .balance | tr -d ' ' >$@

$(VCADDR)/adl%:
	rm -f $@
	$(foreach a,$(DA$*),jq -r .config.addr $(ETC)/$a | xargs printf "%s\t%s\n" $a >>$@;)
$(VCADDR)/da%:
#	jq -r .config.addr $^ | xargs echo
	jq -r .config.addr $(patsubst %,$(ETC)/%,$(DA$*)) | xargs echo >$@

tna:
	./que.sh $(aa) "$(DA$(al))"
ta:
	./que.sh $(aa) "$(DA$(al))" | column -t

bbb: $(patsubst %,$(ETC)/%,$(DA2))
	./que.sh aba "$^"
#bbb: $(patsubst %,$(ETC)/%,$(SC2))
#	jq -r .config.addr $^ | xargs echo | xargs $(TOC67) account | jq -rs '.[] | map_values(.balance?)[]'

ta1: $(wildcard $(ETC)/X$(MWN)/*) $(patsubst %,$(ETC)/Y$(PRN)/%/$U,$(UL)) $(addprefix $(ETC)/,X2/$W $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T))
	$(foreach a,$^,d=`jq -r .config.addr $a`;$(_gqq) transactions(filter:{account_addr:{eq:\"'$$d'\"} now:{ge:$(HX)} aborted:{eq:true}}) {account_addr now_string compute{exit_code}} $(_gqe)transactions[]';)
#ta2: #$(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T) $(patsubst %,Y$(PRN)/%/$U,$(UL))
##	$(foreach a,X2/$W $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T),./que.sh $a | xargs echo;)
##	$(foreach a,X2/$W $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T),./que.sh $a | xargs echo;)
#	./que.sh errors "X2/$W $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T)"  | column -t
#ta3:
#	./que.sh balance "X2/$W $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T)"  | column -t
#ta4:
#	./que.sh spent "X2/$W $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T)" | column -t
##{account_addr now_string compute{exit_code}}
_tra=transactions(filter:{account_addr:{eq:\"'$1'\"} now:{ge:$(HX)} aborted:{eq:true}})
$(HX)/%.sY$(PRN):
	$(foreach a,$(patsubst %,$(ETC)/Y$(PRN)/%/$*,$(UL)),$(_gqq)$(call _trx,$(HX),$(shell jq -r '.config.addr' $a)) $(_r77)$(_gqe)$(_f78)' >>$@;)
$(HX)/%$R.s:
	$(_gqq)$(call _atrx,$(HX),$(shell jq -r '.config.addr' $(ETC)/$*$R)) $(_r2)$(_gqe)$(_f1)' >$@
$(HX)/%.s$(PRN):
	$(_gqq)$(call _atrx,$(HX),$(shell jq -r '.config.addr' $(AD)/$*)) $(_r2)$(_gqe)$(_f1)' >$@
$(HX)/%.sX$(MWN): $(ETC)/X$(MWN)/%
	$(_gqq)$(call _atrx,$(HX),$(shell jq -r '.config.addr' $<)) $(_r2)$(_gqe)$(_f1)' >$@
$(HB)/msb: $(patsubst %,$(HB)/%.b,$(RROOTS)) $(patsubst %,$(HB)/%.bX$(MWN),$W $B $F $T $B$T) $(patsubst %,$(HB)/%.b$(PRN),$P $U$R $D$W $(IB) $D$W$T) $(patsubst %,$(HB)/%.bY$(PRN),$U $I $S $I0)
	$(foreach a,$^,paste $a -sd+ | bc | xargs printf "%.03g\t" >>$@; printf "%s\n" $(basename $(notdir $a)) >>$@;)
$(HX)/msp: $(patsubst %,$(HX)/%.s,$(RROOTS)) $(patsubst %,$(HX)/%.sX$(MWN),$W $B $F $T $B$T) $(patsubst %,$(HX)/%.s$(PRN),$P $U$R $D$W $(IB) $D$W$T) $(patsubst %,$(HX)/%.sY$(PRN),$U $I $S $I0)
	$(foreach a,$^,$(call _sum3,$a) | xargs -I{} printf "%.03g\t%s\n" {} $(basename $(notdir $a)) >>$@;)
_cmp=join -j2 -o 1.1 2.1 1.2 $1 $2 | tr ' ' '\t'
msc: $(HB)/msb $(HX)/msp
#	join -j2 -o 1.1 2.1 1.2 $^ | tr ' ' '\t'
	$(call _cmp,$^)
b1?=$(HB)
b2?=$(HB)

cmpb: $(b1)/msb $(b2)/msb
	$(call _cmp,$^)
#msc:
#	$(foreach a,$(RROOTS),printf "%-26s" $a; cat $(HX)/$a.b | xargs printf "%.03g\t";paste $(HX)/$a.s -sd+ | tr '\t' + | xargs printf "scale=3;(%s) / 1000000000\n" | bc | xargs printf "%.03g\n";)
#	$(foreach a,$P $U$R $D$W $(IB) $D$W$T,printf "%-26s" $a; cat $(HX)/$a.b$(PRN) | xargs printf "%.03g\t";paste $(HX)/$a.s$(PRN) -sd+ | tr '\t' + | xargs printf "scale=3;(%s) / 1000000000\n" | bc | xargs printf "%.03g\n";)
#	$(foreach a,$U $I $I0,printf "%-26s" $a; paste $(HX)/$a.bY$(PRN) -sd+ | bc | xargs printf "%.03g\t";paste $(HX)/$a.sY$(PRN) -sd+ | tr '\t' + | xargs printf "scale=3;(%s) / 1000000000\n" | bc | xargs printf "%.03g\n";)
news:
	mkdir -p $(HB)
mrr:
	$(eval od!=date +%s)
	mkdir -p $(od)
	$(foreach a,$(addprefix $(ETC)/,X1/$W X2/$W $(RROOTS)),$(TOC) -c $a account | jq -r .balance >$(od)/$(subst /,,$a);)
#	$(call _ex,$(addprefix $(ETC)/,X1/$W X2/$W $(RROOTS)),$(od)/root)
#	$(call _ex,$(addprefix $(ETC)/,$(patsubst %,Y$(PRN)/%,$P $U$R $D$W $(IB) $D$W$T)),$(od)/system)
#	$(call _pageto,$(SC4),_ab0,$(od)/unit)
mr2:
	$(eval of!=date +%s)
	rm -f ex8 bx7
	$(call _ex,$(addprefix $(ETC)/,X2/$W $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T)),ex8)
	$(call _sum,ex8) >$(of)
	$(call _pageto,$(SC4),_ab0,bx7)
	$(call _sum,bx7) >>$(of)
	cat $(of)
mc2:
	mv $(patsubst %,mx.%,$U $S $T main) bak
ms2: $(patsubst %,mx.%,$U $S $T main)
	$(eval of=s_$(shell date +%s))
	$(foreach a,$^,$(call _sum2,$a) >>$(of);)
	cat $(of)
	$(call _sum2,$(of))

bx: $(SC4)
	$(call _page,$^,_ab)
	$(call _sum,$@)
#	paste $@ -sd+ | bc

#	$(foreach a,$^,$(TOC) account `jq -r .config.addr $a`;)
s1: ;	$(call _gg2,G,PRN,$P)
s2: ;	$(call _gg2,G,PRN,$U$R)
s3: ;	$(call _gg3,G,WN,$U,UL)
t1: ;	$(call _gg2,G,WN,$B)
t2: ;	$(TOC) -c $(ETC)/X0/$B runx -m getBulkSellGasFee --answerId 1 --amount 10
t3: ;	$(foreach i,$(WN),$(TOC) -c $(ETC)/X$i/$W account | jq -r .balance;)
t4: ;	$(foreach a,$(PRN),$(foreach i,$(UL),$(TOC) -c $(ETC)/Y$a/$U$i account | jq -r .balance;))
t5: ;	$(foreach a,$(PRN),$(foreach i,$(UL),$(TOC) -c $(ETC)/Y$a/$T$i account | jq -r .balance;))

y1:
#	echo $(G_$B$R)
	$(call _gg1,$B$R $P$R $F$R)
t6:
	$(foreach a,$(WN),$(TOC) -c $(ETC)/$T$R runx -m walletOf --answerId 1 --walletOwner `$AX$a/$W` | jq -r .value0;)

b0: $(wildcard $(ETC)/*)
	$(foreach a,$^,$(TOC) -c $a account | jq -r .balance;)
#b1: $(patsubst %,$(ETC)/Y1/$U%,$()) $(ETC)/Y1/$U$R $(ETC)/Y1/$D$W $(ETC)/Y1/$P $(ETC)/Y1/$D$W$T
#	$(foreach a,$^,$(TOC) -c $a account | jq -r .balance;)
b2: $(wildcard $(ETC)/*/*$T*)
	$(foreach a,$^,$(TOC) -c $a runx -m balance --answerId 1 | jq -r .value0;)
#	echo $^
d1:
	$(eval owner!=$AX1/$W)
	$(eval bwr!=$A$B$R)
	jq -n '{owner:"$(owner)",json:"{}",userProfileCollection:"$(owner)",bulkWorkerRoot:"$(bwr)",sendGasTo:"$(owner)",royaltyReceiver:"$(owner)",approvedAddress:"$(owner)",supervisor:"$(owner)",royalty:0,numOfUnits:100,currentIteration:28}'
	$(TOC) -c $(ETC)/Y0/$U$R debug run -m amint `jq -nc '{owner:"$(owner)",json:"{}",userProfileCollection:"$(owner)",bulkWorkerRoot:"$(bwr)",sendGasTo:"$(owner)",royaltyReceiver:"$(owner)",approvedAddress:"$(owner)",supervisor:"$(owner)",royalty:0,numOfUnits:100,currentIteration:28}'`

#_q1=counterparties(account: \"'$1'\") {counterparty}
#_q2=transactions(filter:{account_addr:{eq:\"'0:836eee61b42ed92b8cc7541db7452736dd26b936485848a44ec6365745925e69'\"}}) {total_fees(format: DEC)}
_q2=transactions(filter:{account_addr:{eq:\"'$1'\"}}) {total_fees(format: DEC)}
_q3=transactions(filter:{account_addr:{eq:\"'$2'\"}} limit:$1) {total_fees(format: DEC)}
_q4=transactions(filter:{account_addr:{eq:\"'$2'\"} now:{gt:$1}}) {total_fees(format: DEC)}
_q5=transactions(filter:{account_addr:{eq:\"'$2'\"} now:{gt:$1}}) {compute {gas_fees(format: DEC)}}
_q6=transactions(filter:{account_addr:{eq:\"'$2'\"} now:{gt:$1}}) {compute {gas_fees(format: DEC)}action {total_action_fees(format: DEC)total_fwd_fees(format: DEC)}}
_r6={compute {gas_fees(format: DEC)}action {total_action_fees(format: DEC)total_fwd_fees(format: DEC)}}
_f6=transactions[]? | (.compute.gas_fees | tonumber) + (try .action.total_action_fees | tonumber) + (try .action.total_fwd_fees | tonumber)
_f7=transactions[]? | "\(.compute.gas_fees) \(if (.action.total_action_fees==null) then 0 else .action.total_action_fees end) \(if (.action.total_fwd_fees==null) then 0 else .action.total_fwd_fees end)"
_r77={storage{storage_fees_collected(format: DEC)}compute{gas_fees(format: DEC)}action {total_action_fees(format: DEC)total_fwd_fees(format: DEC)}}
_f77=transactions[]? | "\(.storage.storage_fees_collected) \(.compute.gas_fees) \(if (.action.total_action_fees==null) then 0 else .action.total_action_fees end) \(if (.action.total_fwd_fees==null) then 0 else .action.total_fwd_fees end)"
_f78=transactions[]? | "\(.compute.gas_fees)	\(if (.action.total_fwd_fees==null) then 0 else .action.total_fwd_fees end)	\(if (.action.total_action_fees==null) then 0 else .action.total_action_fees end)	\(.storage.storage_fees_collected)"
_r8=fields:[{field:\"storage.storage_fees_collected\"fn:SUM}{field:\"compute.gas_fees\"fn:SUM}{field:\"action.total_action_fees\"fn:SUM}{field:\"action.total_fwd_fees\"fn:SUM}])
_r9=fields:[{field:\"storage.storage_fees_collected\"fn:COUNT}])
_f8=aggregateTransactions[]?
_agf={field:\"$1\"fn:SUM}
_agv=$(foreach a,$1,{field:\"$a\"fn:SUM})
_r1=fields:[{field:\"compute.gas_fees\"fn:SUM}{field:\"action.total_fwd_fees\"fn:SUM}{field:\"action.total_action_fees\"fn:SUM}{field:\"storage.storage_fees_collected\"fn:SUM}])
_r2=fields:[$(patsubst %,{field:\"%\"fn:SUM},compute.gas_fees action.total_fwd_fees action.total_action_fees storage.storage_fees_collected)])
#	$(call _agv,compute.gas_fees action.total_fwd_fees action.total_action_fees storage.storage_fees_collected)])
_f1=aggregateTransactions | @tsv
_gqq=curl -sS -X POST 'https://$(URL)/$(PID)/graphql' -g -H "Authorization: Basic $(AK)" -H "Content-Type: application/json" -d  '{"query": "query {
_gqe=}"}' | jq -r '.data.
_trx=transactions(filter:{account_addr:{eq:\"'$2'\"} now:{ge:$1}})
_tra=transactions(filter:{account_addr:{eq:\"'$2'\"} aborted:{eq:true}})
#{account_addr now_string compute{exit_code}}
_atrx=aggregateTransactions(filter:{account_addr:{eq:\"'$2'\"} now:{ge:$1}}
#_att=$(call _atrx,$(HX),$(shell jq -r '.config.addr' $1))
_sp=$(call _gq,$(call _q3,$1,`$A$2`)) | jq -r .transactions[].total_fees >>$@
_mp=$(call _gq,$(call _q3,$1,`$A$3`)) | jq -r '.transactions[].total_fees | tonumber * $2' >>$@
_mp1=$(call _gq,$(call _q4,$1,`$A$2`)) | jq -r '.transactions[].total_fees | tonumber'
_mp2=$(call _gq,$(call _q5,$1,`$A$2`)) | jq -r '.transactions[].compute.gas_fees | tonumber'
_mp3=$(call _gq,$(call _q6,$1,`$A$2`)) | jq -r '.transactions[]? | (.compute.gas_fees | tonumber) + (try .action.total_action_fees | tonumber) + (try .action.total_fwd_fees | tonumber)'
_mp4=$(call _gq2,$(call _q6,$1,`$A$2`),.transactions[]? | (.compute.gas_fees | tonumber) + (try .action.total_action_fees | tonumber) + (try .action.total_fwd_fees | tonumber)')
_mp5=$(_gqq)$(call _trx,$1,$2) $(value $3)$(_gqe)$(value $4)'
_mp6=$(_gqq)$(call _atrx,$1,$2) $(value $3)$(_gqe)$(value $4)'
_mp7=$(_gqq)$(call _atrx,$1,$2) $3$(_gqe)$4'

SCOS1=$S$R $T$R X2/$B X2/$W
SCOS2=$(patsubst %,Y0/%/$U,$(UL)) $(patsubst %,Y0/%/$S,$(UL)) $(patsubst %,Y0/%/$T,$(UL))
mx.%:
	$(foreach a,$(patsubst %,Y0/%/$*,$(UL)),$(call _mp5,$(HX),$(shell $A$a),_r77,_f77) >>$@;)
mx.main:
#	$(foreach a,$(SCOS1),$(call _mp5,1703259670,$(shell $A$a),_r6,_f7) >>$@;)
	$(foreach a,$(SCOS1),$(call _mp6,$(HX),$(shell $A$a),_r8,_f8) >>$@;)
mct:
	$(foreach a,$(SCOS1),$(call _mp6,$(HX),$(shell $A$a),_r9,_f8);)
_gq=curl -sS -X POST 'https://$(URL)/$(PID)/graphql' -g -H "Authorization: Basic $(AK)" -H "Content-Type: application/json" -d  '{"query": "query {$1}"}'  | jq -r .data
_gq2=curl -sS -X POST 'https://$(URL)/$(PID)/graphql' -g -H "Authorization: Basic $(AK)" -H "Content-Type: application/json" -d  '{"query": "query {$1}"}'  | jq -r '.data$2
tr_%: $(ETC)/%
	$(call _gq,$(call _q2,`jq -r '.config.addr' $<`)) | jq -r .transactions[].total_fees
tt: $(ETC)/Y0/1/Unit
	$(call _gq,$(call _q3,1,`jq -r '.config.addr' $<`)) | jq -r .transactions[].total_fees
	$(call _gq,$(call _q3,2,`jq -r '.config.addr' $(ETC)/Y0/1/$S`)) | jq -r .transactions[].total_fees
tt2:
	$(call _gq,$(call _q3,5,`jq -r '.config.addr' $(ETC)/X2/$B`)) | jq -r .transactions[].total_fees
tt3:
	$(call _gq,$(call _q3,50,`jq -r '.config.addr' $(ETC)/X2/$W`)) | jq -r .transactions[].total_fees
ts:
	$(call _gq,$(call _q3,3,`jq -r '.config.addr' $(AD)/1/$U`)) | jq -r .transactions[].total_fees
	$(call _gq,$(call _q3,4,`jq -r '.config.addr' $(AD)/1/$S`)) | jq -r .transactions[].total_fees
	$(call _gq,$(call _q3,2,`jq -r '.config.addr' $(ETC)/$S$R`)) | jq -r .transactions[].total_fees
ts4:
	$(call _gq,$(call _q3,50,`jq -r '.config.addr' $(ETC)/$T$R`)) | jq -r .transactions[].total_fees
ts5:
	$(call _gq,$(call _q3,1,`jq -r '.config.addr' $(AD)/1/$T`)) | jq -r .transactions[].total_fees
tca:
	$(call _sp,1,Y0/1/$U)
	$(call _sp,2,Y0/1/$S)
	$(call _sp,1,X2/$B)
	$(call _sp,2,X2/$W)
#	paste $@ -sd+ | bc
	$(call _sum,$@)
tse:
	$(call _sp,3,Y0/1/$U)
	$(call _sp,4,Y0/1/$S)
	$(call _sp,2,$S$R)
	$(call _sp,1,Y0/1/$T)
	$(call _sp,2,$T$R)
	$(call _sp,1,X2/$B)
	$(call _sp,6,X2/$W)
	$(call _sum,$@)
#	paste $@ -sd+ | bc
tme:
	$(call _sp,3,Y0/1/$U)
	$(call _sp,4,Y0/1/$S)
	$(call _sp,2,$S$R)
	$(call _sp,1,Y0/1/$T)
	$(call _sp,1,$T$R)
	$(call _sp,1,X2/$B)
	$(call _mp,1,6,X2/$W)
	$(call _sum,$@)

#function mint( address owner, string json, address userProfileCollection, address bulkWorkerRoot, address sendGasTo, address royaltyReceiver, address approvedAddress, address supervisor, uint8 royalty, uint32 numOfUnits, uint32 currentIteration ) external virtual {
tm: ; $(TOC) -c $(ETC)/$Q.conf callx -m act --op 2 --src 0 --dst 0 --val 1000000000000 --fee 0

fn_%: $(BLD)/%.abi.json
	jq -rc '.functions[] | "\(.name)"' $<
	jq -rc '.functions[] | "\(.name),\(.inputs[].name),\(.outputs[].name)"' $<
#	jq -rc '.functions[] | "\(.name),\(reduce(.inputs[]) as $$f (" "; .+=" " + $$f.name)),\(reduce(.outputs[]) as $$f (" "; .+=" " + $$f.name))"' $<

g01: ; $(foreach a,$(RDIRS),$(TOC) -c $(ETC)/$a$R account | jq -r .acc_type;)
g1:	 ; $(call _gg1,$(RROOTS))
g21: ; $(call _gg2,G,WN,$B $F $T)
g22: ; $(call _gg2,G,PRN,$P $U$R $D$W $(IB))
#g23: ; $(call _gg2,G,PN,$(IB))
#-include g3.mk
g31: ; $(call _gg3,G,PRN,$U,UL)
g32: ; $(call _gg3,G,PRN,$S,UL)
g33: ; $(call _gg3,G,PRN,$T,UL)
g34: ; $(call _gg3,G,PRN,$I,UL)
i1:  ;	$(foreach f,$(P),$(foreach j,$(I_$f),$($f.$j);))
i01: ;	$(call _gg2,I,WN,$B $F $T)
i02: ;	$(call _gg2,I,PRN,$P $U$R $D$W $(IB))
i05: ;	$(call _gg3,I,PRN,$U,UL)
i06: ;	$(call _gg3,I,PRN,$S,UL)
i07: ; 	$(call _gg3,I,PRN,$T,UL)
i08: ;	$(call _gg2,I,PRN,$(IB))

elist clist hlist alist rlist:
	$(TOC) -c $(ETC)/$Q.conf runx -m $@ | jq -r .out

#_ae=$(C$L) add_ext "`cat $(wildcard $(TD)/$1.addr) | tr : x | jq -Rcs --argjson n $2 '{n:$$n,aa:split("\n")[0:-1]'}`"
#e1:
#	$(call _aa,$(BW),1)
#ea:
#	$(call _ae,$(BW),1)
#	$(call _ae,$(BWR),2)
#	$(call _ae,$(I),4)
#	$(C$L) add_ext '{"n":4,"aa":["0x09c6a2b79f12ffb23b512b7fe2690f85312544ef6e9d04c2fc260830420ca970","0x4e467531ae4bdea9ab7e7ae31c2b89910556869edbf8a740f16908bdb95b7dce","0xc41d60d675f09dbf84313500ba414147a9c1d3ad844a036e3d377a274fec3446","0x73ac2d890429113694088e9840a717bfa72c3971a6937f8237cf47e1dfeb07d2","0x4ab46c5020d22cd202b04b55801b9bc7b60f32dd0cacb962ac692730e4eae2a1","0x5e3cab2984c4ccb92908251268366e1cf824c1dcbb8d974499d339c2bcaf6361"]}'
#	$(C$L) add_ext '{"n":5,"aa":["0xf62ddf12f01ef3060c82972a72941a2ae918b1dcaf680fa52f8348b80cd8d6d1","0x7aedf2efa103327eea2596f520c6faa86ea14f4191dafa945e0926b14d21f147"]}'
#	$(call _ae,$(IB),5)
#	$(call _ae,$(P),6)
#	$(call _ae,$(PR),7)
#	$(call _ae,$(TR),8)
#	$(call _ae,$(TW),9)
#	$(call _ae,$(USR),13)
#	$(call _ae,$(UP),14)
#	$(call _ae,$(UPR),15)
#	$(call _ae,$(W),16)
#	$(call _ae,$(DW),3)
#	$(call _ae,$(UR),11)
#	$(call _ae,$(U),10)

#SC2=$(patsubst %,Y$(PRN)/$T%,$(shell seq 0 99))
#SC2=$(wildcard $(ETC)/Y$(PRN)/*)
#$(wildcard $(ETC)/Y$(PRN)/*/*)
#bbb: $(patsubst %,$(ETC)/%,$(SC2))
#	jq -r .config.addr $^ | xargs echo | xargs $(TOC67) account | jq -rs '.[] | map_values(.balance?)[]'
#_page=$(call $1,$(wordlist 1,50,$2));$(if $(wordlist 51,$(words $2),$2),$(call _page,$1,$(wordlist 51,$(words $2),$2)),$(call $1,$(wordlist 51,$(words $2),$2)))
#$(call $1,$(wordlist 1,50,$2))
#_head=$(wordlist 1,50,$1)
#_tail=$(wordlist 51,$(words $1),$1)
#head=$(wordlist 1,50,$2)
#tail=$(wordlist 51,$(words $2),$2)
#$(call $2,$(call _head,$1))
#$(eval tt:=$(call _tail,$1))
#$(if $(tt),$(call _page,$(tt),$2))
#$(if $(tt),$(call _page,$(tt),$2,$(call $2,$(tt))))
#$(if $(call _tail,$1),$(call _page,$(call _tail,$1),$2,$(call $2,$(call _tail,$1))))
#echo H: $(head) T: $(tail)
#$(if wordlist 51,$(call $1,$(wordlist 1,50,$2))
#$(if $(wordlist 51,$(words $2),$2),$(call _page,$1,$(wordlist 51,$(words $2),$2)),$(call $1,$(wordlist 51,$(words $2),$2)))
#	$(call _ab,$(patsubst %,$(ETC)/%,$(SC2)))
#	$(foreach a,$^,echo $(notdir $a))
#	paste $@ -sd+ | bc
#	$(call _gq,$(call _q3,1,`jq -r '.config.addr' $(AD)/1/$U`)) | jq -r .transactions[].total_fees
#	$(call _gq,$(call _q3,2,`jq -r '.config.addr' $(AD)/1/$S`)) | jq -r .transactions[].total_fees
#	$(call _gq,$(call _q3,1,`jq -r '.config.addr' $(ETC)/X2/$B`)) | jq -r .transactions[].total_fees
#	$(call _gq,$(call _q3,2,`jq -r '.config.addr' $(ETC)/X2/$W`)) | jq -r .transactions[].total_fees
#	$(call _gq,$(call _q3,50,`jq -r '.config.addr' $(ETC)/X2/$B$T`)) | jq -r .transactions[].total_fees
#0:836eee61b42ed92b8cc7541db7452736dd26b936485848a44ec6365745925e69
#	$(call _gq,$(call _q2,$A$S$R)) | jq -r .transactions[].total_fees
#	 | jq -r '.counterparties[][]' | sort >$@
#$(HX)/s_Y$(PRN)%:
#	$(foreach a,$(patsubst %,$(ETC)/Y$(PRN)/%/$*,$(UL)),$(_gqq)$(call _trx,$(HX),$(shell jq -r '.config.addr' $a)) $(_r77)$(_gqe)$(_f78)' >>$@;)
#$(HX)/s_%$R:
#	$(_gqq)$(call _atrx,$(HX),$(shell jq -r '.config.addr' $(ETC)/$*$R)) $(_r2)$(_gqe)$(_f1)' >$@
#$(HX)/s_$(PRN)%:
#	$(_gqq)$(call _atrx,$(HX),$(shell jq -r '.config.addr' $(AD)/$*)) $(_r2)$(_gqe)$(_f1)' >$@
#	$(eval a!=jq -r '.config.addr' $<)
#	$(info query=$(call _q2,$a))
#	$(eval query=$(call _q2,))
#	echo q: $(query)
#	$(call _gq,$(query)) | jq -r .transactions[].total_fees
#	$(call _gq,$(call _q2,$(shell jq -r '.config.addr' $<))) | jq -r .transactions[].total_fees
#mcm:
#	rm -f $@
#	$(foreach a,$(SCOS1),$(call _mp6,1703259670,$(shell $A$a),_r8,_f8) >>$@;)
#	$(call _sum2,$@)
#m6: $(patsubst %,mx.%,$U $S $T main)
#	$(eval of=s_$(shell date +%s))
#	$(foreach a,$^,$(call _sum2,$a) >>$(of);)
#	cat $(of)
#	$(call _sum2,$(of))
#m5:
#	$(eval of=s_$(shell date +%s))
#	rm -f mx5 mx6 mx7 mx8
#	$(foreach a,$(SCOS1),$(call _mp5,1703259670,$(shell $A$a),_r6,_f7) >>mx5;)
#	$(call _sum2,mx5) >$(of)
#	$(foreach a,$(patsubst %,Y0/%/$U,$(UL)),$(call _mp5,1703259670,$(shell $A$a),_r6,_f7) >>mx6;)
#	$(call _sum2,mx6) >>$(of)
#	$(foreach a,$(patsubst %,Y0/%/$U,$(UL)),$(call _mp5,1703259670,$(shell $A$a),_r6,_f7) >>mx7;)
#	$(call _sum2,mx7) >>$(of)
#	$(foreach a,$(patsubst %,Y0/%/$U,$(UL)),$(call _mp5,1703259670,$(shell $A$a),_r6,_f7) >>mx8;)
#	$(call _sum2,mx8) >>$(of)
#	cat $(of)
#m4:
#	rm -f mx1 mx2
#	$(eval of=s_$(shell date +%s))
##	$(call _mp5,1703259670,$(shell $AY0/1/$U),_r6,_f6)
#	$(foreach a,$(SCOS1),$(call _mp5,1703259670,$(shell $A$a),_r6,_f6) | tee -a mx1;)
##	$(foreach a,$(UL),$(call _mp5,1703259670,$(shell $AY0/$a/$U),_r6,_f6) | tee -a mx2;)
##	$(foreach a,$(UL),$(call _mp5,1703259670,$(shell $AY0/$a/$S),_r6,_f6) | tee -a mx3;)
##	$(foreach a,$(UL),$(call _mp5,1703259670,$(shell $AY0/$a/$T),_r6,_f6) | tee -a mx4;)
##	$(call _mp3,1703259670,Y0/1/$S) >>mx
##	$(call _mp3,1703259670,$S$R) >>mx
##	$(call _mp3,1703259670,Y0/1/$T) >>mx
##	$(call _mp3,1703259670,$T$R) >>mx
##	$(call _mp3,1703259670,X2/$B) >>mx
##	$(call _mp3,1703259670,X2/$W) >>mx
#	$(call _sum,mx1) >$(of)
##	$(call _sum,mx2) >>$(of)
##	$(call _sum,mx3) >>$(of)
##	$(call _sum,mx4) >>$(of)
#	cat $(of)
##	$(call _sum,$@)
#_gg1=$(foreach f,$1,printf "%s:\n" $f;$(foreach j,$(G_$f),printf "\t%s: " $j;$($f.$j);))
#_gg2=$(foreach a,$($2),printf "%s:\n" $a;$(foreach f,$3,printf "%s:\n" $f;$(foreach j,$($1_$f),printf "\t%s: " $j;$($f.$j$a);)))
#define gg2
#_gg2=$(foreach a,$($2),printf "%s:\n" $a;$(foreach f,$3,printf "%s:\n" $f;$(foreach j,$($1_$f),printf "\t%s: " $j;$($f.$j$a);)))
#_gg3=$(foreach f,$1,printf "%s:\n" $f;$(foreach j,$($2_$f),printf "\t%s:\n" $j;$(foreach a,$3,printf "\t\t%s:\n" $a;$(foreach i,$($4$a),printf "\t\t\t%s: " $i;$($f$i.$j$a);))))
#_gg3=$(foreach a,$3,printf "%s:" $a;$(foreach f,$1,printf "%s:\n" $f;$(foreach j,$($2_$f),printf "%s:\n" $j;$(foreach i,$($4$a),printf "\t%s%s: " $f $i;$($f$i.$j$a);))))
#_mp5=curl -sS -X POST 'https://$(URL)/$(PID)/graphql' -g -H "Authorization: Basic $(AK)" -H "Content-Type: application/json" -d  '{"query": "query {$(call _trx,$1,$2) $3}"}' | jq -r '.data.$4'
#_mp5=$(_gqq)$(call _trx,$1,$2) $3}"}' | jq -r '.data.$4'
#_mp7=$(_gqq)$(call _atrx,$1,$2) $($3)$(_gqe)$($4)'
# {compute {gas_fees(format: DEC)}action {total_action_fees(format: DEC)total_fwd_fees(format: DEC)}}}"}'
#$(call _gq,$(call _trx,$1,$2)){compute {gas_fees(format: DEC)}action {total_action_fees(format: DEC)total_fwd_fees(format: DEC)}}
#$(call _q6,$1,`$A$2`),.transactions[]? | (.compute.gas_fees | tonumber) + (try .action.total_action_fees | tonumber) + (try .action.total_fwd_fees | tonumber)')
# | jq -r '.transactions[].compute.gas_fees | tonumber'
#_q2=transactions(filter:{account_addr:{eq:\"'jq -r '.config.addr' $<'\"}}) {total_fees(format: DEC)}
#m1:
#	$(call _sp,3,Y0/1/$U)
#m2:
#	$(call _mp1,$,$(shell $AY0/1/$U))
#m3:
##	$(eval of!=date +%s)
#	rm -f mx
#	$(eval of=s_$(shell date +%s))
#	$(call _mp3,1703259670,Y0/1/$U) >>mx
#	$(call _mp3,1703259670,Y0/1/$S) >>mx
#	$(call _mp3,1703259670,$S$R) >>mx
#	$(call _mp3,1703259670,Y0/1/$T) >>mx
#	$(call _mp3,1703259670,$T$R) >>mx
#	$(call _mp3,1703259670,X2/$B) >>mx
#	$(call _mp3,1703259670,X2/$W) >>mx
#	$(call _sum,mx) >$(of)
#	cat $(of)
#$(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T)
#	$(call _pageto,$(SC4),_ab0,bx7)
#	$(call _sum,bx7) >>$(of)
#	$(call _pageto,$(SC4),_ab0,bx7)
#	$(call _sum,bx7) >>$(of)
#	$(call _ex,$(addprefix $(ETC)/,$(patsubst %,Y$(PRN)/%,$P $U$R $D$W $(IB) $D$W$T)),ex8)
#	$(call _sum,ex8) >$(of)
#SCOPE=$(patsubst %,X%/$W,$(WN)) $(RROOTS) $(patsubst %,Y$(PRN)/%,$P $U$R $D$W $D$W$T)
#SCOPE=$(patsubst %,X%/$W,$(WN)) $(RROOTS) $(patsubst $(ETC)/%,%,$(wildcard $(ETC)/Y$(PRN)/*))
#ex: $(patsubst %,$(ETC)/X%/$W,$(WN)) $(patsubst %,$(ETC)/%,$(RROOTS))
#ex: $(patsubst %,$(ETC)/%,$(SCOPE))
#ee:
#	$(MAKE) -s -C var/lib/aconf -f expand.mk m1
#ee2:
#	$(MAKE) -s -C var/lib/aconf -f expand.mk m2
#ee3:
#	$(MAKE) -s -C var/lib/aconf -f expand.mk m3
#_confg=printf "%s\t%s\n" $1 "$2"
#_clistd=printf "%s\t%s\n" $1 "$(addprefix $$,$2)"
#_clistd2=printf "%s\t%s\n" $1 $(patsubst %,$$(%),$2)
#_confg2=$(call _confg,$(firstword $1),$(firstword $2)) $(if $(word 2,$1),$(call _confg2,$(wordlist 2,$(words $1),$1),$(wordlist 2,$(words $2),$2)))
#_co2=$(foreach a,$(shell seq 1 $(words $1)),printf "%s\t%s\n" $(word $a,$1) $(word $a,$2) >>$3;)
##.SECONDEXPANSION:
#.SILENT: coo co2 co3
#coo:
#	$(eval of=$(CCONF)/ctx.def)
#	rm -f $(of)
#	$(call _co2,Q R W I C N F B P T U S D IB,qloy Root Wallet Index Collection Nft UserProfile BulkWorker Property Token Unit $USell Distributions $IBasis,$(of))
#	$(call _clistd,RDIRS,B P T S F) >>$(of)
#	$(call _confg,RROOTS,$(patsubst %,%$R,$(RDIRS))) >>$(of)
#	$(call _clistd,RUS,U T S) >>$(of)
#co2:
#	$(call _co2,U_dev U_fld U_rfld U_venom NET URL PID AK,devnet.evercloud.dev gql.custler.net rfld-dapp.itgold.io venom-testnet.evercloud.dev dev $(U_$(NET)) 2e786c9575af406fa784085c88b5e7e3 38f728004a4b40e2a8aa30f8fee45346,1)
#.SECONDEXPANSION:
#co3:
#	$(call _co2,BLD ETC TMP VAR LIB LOG CACHE SNAP TMP CADDR CCONF,build etc tmp var $(VAR)/lib $(VAR)/log $(VAR)/cache $(VAR)/snap $(VAR)/tmp $(CACHE)/address $(CACHE)/ctxconfig,1)
#	printf "%s\t%s\n" DIRS "$(addprefix $$$$,$(patsubst %,(%),BLD ETC TMP VAR LIB LOG CACHE SNAP TMP CADDR CCONF))" >>1
#	$(call _clistd,DIRS,$(patsubst %,(%),BLD ETC TMP VAR LIB LOG CACHE SNAP TMP CADDR CCONF)) >>1
#U_dev:=devnet.evercloud.dev
#U_fld:=gql.custler.net
#U_rfld:=rfld-dapp.itgold.io
#U_venom:=venom-testnet.evercloud.dev
#NET:=dev
#URL:=$(U_$(NET))
#TOOLS_BIN?=$(R_ROOT)/bin
## Tools directories
#TOC?=$(TOOLS_BIN)/tonos-cli
#BLD?=build
#ETC?=etc
#TMP?=tmp
#PID:=2e786c9575af406fa784085c88b5e7e3
#AK:=38f728004a4b40e2a8aa30f8fee45346
#A=jq -r '.config.addr' $(ETC)/
#	@$(call _confg2,Q R W I C N F B P T U S D IB,qloy Root Wallet Index Collection Nft UserProfile BulkWorker Property Token Unit $USell Distributions $IBasis) >$(CCONF)/ctx.def
#$(CCONF)/ctx.def:
#	$(file >$@,$(call _confg2,Q R W I C N F B P T U S D IB,qloy Root Wallet Index Collection Nft UserProfile BulkWorker Property Token Unit $USell Distributions $IBasis))
#	$(call _clistd,RDIRS,B P T S F) >>$@
#	$(call _confg,RROOTS,$(patsubst %,%$R,$(RDIRS))) >>$@
#	$(call _clistd,RUS,U T S) >>$@
#RDIRS:=$B $P $T $S $F
#RROOTS:=$(patsubst %,%$R,$(RDIRS))
#RUS:=$U $T $S
#CCALL:=$W $(RDIRS) $(RROOTS) $U $U$R $D$W $I $(IB) $C $N
#cconf:
#	$(call _confg,ORD,$(shell seq 1 16))
#	$(call _confg,COX,$B $B$R $D$W $I $(IB) $P $P$R $T$R $T $U $U$R $S $S$R $F $F$R $W)
#	$(call _confg,RDIRS,$B $P $T $S $F)
#RDIRS:=$B $P $T $S $F
#RROOTS:=$(patsubst %,%$R,$(RDIRS))
#RUS:=$U $T $S
#	$(call _confg,$R,$(COX))
#$(CCONF)/groups.ctx:
#	printf "%s\t%s\n" ordinal "$(shell seq 1 16)" >>$@
#$P $U$R $D$W $D$W$T $(IB)
#$(CCONF)/$R.grp:
#tx1c: $(patsubst %,$(ETC)/Y0/$S%,$(UN0))
#	$(foreach a,$^,$(TOC) -c $a runx -m getOfferInfo --answerId 1 | jq -r .;)
#cs: $(patsubst %,$(ETC)/Y0/$S%,$(UN0))
#	$(foreach a,$^,$(TOC) -c $a account | jq -r .acc_type;)
#csu2: $(patsubst %,$(ETC)/Y0/$U%,$(UN0))
#	$(foreach a,$^,$(TOC) -c $a runx -m getInfo --answerId 1 | jq -r .;)
#csw: $(patsubst %,$(ETC)/Y0/$U%,$(UN0))
#	$(foreach a,$^,$(TOC) -c $a runx -m getWithdrawnAmt --answerId 1 | jq -r .;)
#css2: $(patsubst %,$(ETC)/Y0/$S%,$(UN0))
#	$(foreach a,$^,$(TOC) -c $a runx -m getStatusType --answerId 1 | jq -r .;)