F = config.file
P = _

#all: Building.Blocks Orthology.Blocks synteny_blocks.txt 

all: Grab.Data Building.Blocks Orthology.Blocks \
           synteny_blocks.txt Genomes.Order

.PHONY: Grab.Data

# STEP 1
Grab.Data:
	@echo "=========== grabbing data from pairwise nets ==========="
	$D/readNets $F
	$D/getSegments $F

# STEP 2
Building.Blocks: $(wildcard *.processed.segs)
	@echo "======= partitioning genomes into building blocks ======"
	$D/partitionGenomes $F > $@

# STEP 3
Orthology.Blocks:
	@echo "=============== making orthology blocks ================"
	$D/makeOrthologyBlocks $F Building.Blocks > $Porthology.blocks.tmp
	awk '{if (NF > 2) {print $$1,$$2} else {print $$0}}' $Porthology.blocks.tmp > $@

# STEP 4
synteny_blocks.txt: Orthology.Blocks
	@echo "=== merging orthology blocks into conserved segments ==="
	$D/orthoBlocksToOrders $F $Porthology.blocks.tmp > $Porder.DS
	$D/makeConservedSegments $F $Porthology.blocks.tmp $Porder.DS > $Pconserved.segments.tmp
	$D/outgroupSegsToOrders $F $Pconserved.segments.tmp > $Porder.OG
	$D/cleanOutgroupSegs $F $Pconserved.segments.tmp $Porder.OG > $Pconserved.segments.tmp2
	awk '{if (NF > 2) {print $$1,$$2} else {print $$0}}' $Pconserved.segments.tmp2 > $@

# STEP 5
Genomes.Order: synteny_blocks.txt
	@echo "======== creating input files for inferring CARs ========"
	$D/createGenomeFile $F $Pconserved.segments.tmp2 > $@

# remove intermediate files
tidy:
	rm -f $P* *.joins *.segs *.Blocks *.Order
