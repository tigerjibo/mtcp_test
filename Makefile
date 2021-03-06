TARGETS = mtcp_server epoll_server
CC = gcc -g -O3
DPDK=1
PS=0

# DPDK LIBRARY and HEADER
DPDK_INC=/home/ray/Downloads/mtcp/dpdk/include
DPDK_LIB=/home/ray/Downloads/mtcp/dpdk/lib/

# mtcp library and header 
MTCP_FLD    =/home/ray/Downloads/mtcp/mtcp/
MTCP_INC    =-I${MTCP_FLD}/include
MTCP_LIB    =-L${MTCP_FLD}/lib
MTCP_TARGET = ${MTCP_LIB}/libmtcp.a

UTIL_FLD = ../../util
UTIL_INC = -I${UTIL_FLD}/include
UTIL_OBJ = ${UTIL_FLD}/http_parsing.o ${UTIL_FLD}/tdate_parse.o


PS_DIR = ../../io_engine/
PS_INC = ${PS_DIR}/include
INC = -I./include/ ${UTIL_INC} ${MTCP_INC} -I${UTIL_FLD}/include
LIBS = ${MTCP_LIB}
ifeq ($(PS),1)
INC += -I{PS_INC}
LIBS += -lmtcp -L${PS_DIR}/lib -lps -lpthread -lnuma -lrt
endif

# CFLAGS for DPDK-related compilation
INC += ${MTCP_INC}
ifeq ($(DPDK),1)
DPDK_MACHINE_FLAGS = $(shell cat /home/ray/Downloads/mtcp/dpdk/include/cflags.txt)
INC += ${DPDK_MACHINE_FLAGS} -I${DPDK_INC} -include $(DPDK_INC)/rte_config.h
endif

ifeq ($(DPDK),1)
LIBS += -m64 -g -O3 -pthread -lrt -march=native -Wl,-export-dynamic ${MTCP_FLD}/lib/libmtcp.a -L../../dpdk/lib -Wl,-lnuma -Wl,-lmtcp -Wl,-lpthread -Wl,-lrt -Wl,-ldl -Wl,--whole-archive -Wl,-lrte_distributor -Wl,-lrte_kni -Wl,-lrte_pipeline -Wl,-lrte_table -Wl,-lrte_port -Wl,-lrte_timer -Wl,-lrte_hash -Wl,-lrte_lpm -Wl,-lrte_power -Wl,-lrte_acl -Wl,-lrte_meter -Wl,-lrte_sched -Wl,-lm -Wl,-lrt -Wl,--start-group -Wl,-lrte_kvargs -Wl,-lrte_mbuf -Wl,-lrte_ip_frag -Wl,-lethdev -Wl,-lrte_malloc -Wl,-lrte_mempool -Wl,-lrte_ring -Wl,-lrte_eal -Wl,-lrte_cmdline -Wl,-lrte_cfgfile -Wl,-lrte_pmd_bond -Wl,-lrte_pmd_vmxnet3_uio -Wl,-lrte_pmd_virtio_uio -Wl,-lrte_pmd_i40e -Wl,-lrte_pmd_ixgbe -Wl,-lrte_pmd_e1000 -Wl,-lrte_pmd_ring -Wl,-lrt -Wl,-lm -Wl,-ldl -Wl,--end-group -Wl,--no-whole-archive
endif

all: mtcp_server epoll_server

mtcp_server.o: mtcp_server.c
	${CC} -c $< ${CFLAGS} ${INC}

mtcp_server: mtcp_server.o
	${CC} $< ${LIBS} ${UTIL_OBJ} -o $@

epoll_server.o: epoll_server.c
	${CC} -c $< ${CFLAGS} ${INC}

epoll_server: epoll_server.o
	${CC} $< ${LIBS} ${UTIL_OBJ} -o $@

clean:
	rm -f *~ *.o ${TARGETS} log_*

distclean: clean
	rm -rf Makefile
