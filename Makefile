EXT	=
VERSION = `grep Build main.c | sed -e 's/^.*"\([^"]*\)".*/\1/' | tr . _`
CPU	= "`uname -m`"
OS	= "__OS`uname -s | sed -e 's/[-\.]/_/g'`"
ARCHIVE	= MySecureShell-$(OSTYPE)-$(CPU)-$(VERSION)

NAME	= MySecureShell$(EXT)
SRC	= main.c string.c	\
	  parsing.c hash.c	\
	  conf.c convert.c	\
	  user.c prog.c	\
	  ip.c
OBJ	= $(SRC:.c=.o)

NAME1	= utils/sftp-who$(EXT)
SRC1	= SftpWho/Main.c SftpServer/SftpWho.c		\
	  conf.c convert.c hash.c user.c parsing.c	\
	  string.c ip.c
OBJ1	= $(SRC1:.c=.o)

NAME2	= utils/sftp-state$(EXT)
SRC2	= SftpState/Main.c
OBJ2	= $(SRC2:.c=.o)

NAME3	= sftp-server_MSS$(EXT)
SRC3	= SftpServer/Buffer.c SftpServer/Encode.c	\
	  SftpServer/Handle.c SftpServer/Send.c		\
	  SftpServer/Sftp.c SftpServer/Util.c		\
	  SftpServer/Log.c
OBJ3	= $(SRC3:.c=.o)

NAME4	= utils/sftp-admin$(EXT)
SRC4	= SftpAdmin/Main.c SftpServer/Buffer.c
OBJ4	= $(SRC4:.c=.o)


FILE	= sftp_config utils/sftp-kill LICENSE README-fr README-en				\
	  install.sh locales_en locales_fr uninstaller.sh
CFLAGS	= -Wall -Wunused -Wpointer-arith -Wno-uninitialized -O2 -D$(OS) -ISftpServer
DEBUG	= 0

ifneq (,$(findstring $(OSTYPE), linux))
	LDFLAGS	=
else
ifneq ($(OSTYPE), )
	LDFLAGS	= -lkvm
endif
endif

ifeq ($(DEBUG), 1)
	CFLAGS	+= -DDODEBUG
	LDFLAGS	+= -ldebug
endif

RM	= rm -f
CC	= gcc
CHMOD	= chmod
TAR	= tar
CP	= cp -pf
STRIP	= strip
FIND	= find
CVS	= cvs
GREP	= fgrep

all	: $(NAME) sftpwho sftpstate sftpserver sftpadmin

$(NAME)	: $(OBJ)
	@echo "Compile binary	[$(NAME)]"
	@$(CC) -o $(NAME) $(OBJ) $(LDFLAGS)
	@$(CHMOD) 711 $(NAME)

sftpwho : $(OBJ1)
	@echo "Compile binary	[$(NAME1)]"
	@$(CC) -o $(NAME1) $(OBJ1) $(LDFLAGS)
	@$(CHMOD) 711 $(NAME1)

sftpstate: $(OBJ2)
	@echo "Compile binary   [$(NAME2)]"
	@$(CC) -o $(NAME2) $(OBJ2) $(LDFLAGS)
	@$(CHMOD) 711 $(NAME2)

sftpserver: $(OBJ3)
	@echo "Compile binary   [$(NAME3)]"
	@$(CC) -o $(NAME3) $(OBJ3) $(LDFLAGS)
	@$(CHMOD) 711 $(NAME3)

sftpadmin : $(OBJ4)
	@echo "Compile binary   [$(NAME4)]"
	@$(CC) -o $(NAME4) $(OBJ4) $(LDFLAGS)
	@$(CHMOD) 711 $(NAME4)

clean	:
	@echo "Delete all objects"
	@$(RM) $(OBJ) $(OBJ1) $(OBJ2) $(OBJ3) $(OBJ4)

fclean	: clean
	@echo "Delete all unecessary files"
	@$(RM) $(NAME) $(NAME1) $(NAME2) $(NAME3) $(NAME4)
	@$(RM) -i `$(FIND) . | grep -F '~'` *.tgz || true

re	: fclean all


package : re
	@echo "Make package"
	@$(STRIP) $(NAME) $(NAME1) $(NAME2) $(NAME3) $(NAME4)
	@echo "Tar package"
	@$(TAR) cfz $(ARCHIVE).tgz $(NAME) $(NAME1) $(NAME2) $(NAME3) $(NAME4) $(FILE)
	@echo "Package done."

source	: fclean
	@echo "Tar the world"
	@$(TAR) cfz MySecureShell-$(VERSION)_source.tgz $(FILE) *.[ch] */*.[ch] Makefile
	@echo "Source package done."

cvs	:
	@echo "Search for missing files in CVS"
	@$(CVS) -q status -R | $(GREP) Status | $(GREP) -v 'Up-to-date' || true

%.o	: %.c
	@echo "Compile		[$<]"
	@$(CC) $(CFLAGS) -c -o $@ $<
