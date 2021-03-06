//gcc -fPIC -DKXVER=3 curlkdb.c -m32 -lcurl -dynamiclib -o libcurlkdb.so -undefined dynamic_lookup
#include "k.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
 
struct MemoryStruct {
  char *memory;
  size_t size;
};

pthread_t *threads[32];
int thrdcnt = 0;
int thread_cnt;
struct threadArgs {
   int kpipe[2];
   int pollfreq;
   int useproxy;
   double tottime;
   pthread_mutex_t mutex;
   struct MemoryStruct mem;
   char exch[50];
   char url[500];
   char sym[20];
   char proxyl[500];
   char kcallbk[50];
};
static char *proxyList;


typedef struct {
  int *array;
  size_t used;
  size_t size;
} Array;

void initArray(Array *a, size_t initialSize) {
  a->array = (int *)malloc(initialSize * sizeof(int));
  a->used = 0;
  a->size = initialSize;
}

void insertArray(Array *a, int element) {
  if (a->used == a->size) {
    a->size *= 2;
    a->array = (int *)realloc(a->array, a->size * sizeof(int));
  }
  a->array[a->used++] = element;
}

void freeArray(Array *a) {
  free(a->array);
  a->array = NULL;
  a->used = a->size = 0;
}
 
 
static CURL *curl;
static CURLcode res;

static struct MemoryStruct chunk;

static size_t
WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp)
{
  size_t realsize = size * nmemb;
  struct MemoryStruct *mem = (struct MemoryStruct *)userp;
  mem->memory = realloc(mem->memory, mem->size + realsize + 1);
  if(mem->memory == NULL) {
    /* out of memory! */ 
    printf("not enough memory (realloc returned NULL)\n");
    return 0;
  }
  memcpy(&(mem->memory[mem->size]), contents, realsize);
  mem->size += realsize;
  mem->memory[mem->size] = 0;
  return realsize;
}


 
#ifdef __cplusplus
extern "C" {
#endif


/*
// code to read file of proxy URLs
int readproxyl()
{
   char buffer[1024] ;
   char *record,*line;
   int i=0,j=0;
   int mat[100][100];
   FILE *fstream = fopen("\myFile.csv","r");
   if(fstream == NULL)
   {
      printf("\n file opening failed ");
      return -1 ;
   }
   while((line=fgets(buffer,sizeof(buffer),fstream))!=NULL)
   {
     record = strtok(line,";");
     while(record != NULL)
     {
     printf("record : %s",record) ;    //here you can put the record into the array as per your requirement.
     mat[i][j++] = atoi(record) ;
     record = strtok(line,";");
     }
     ++i ;
   }
   return 0 ;
 }
*/

K kcallback(int pipe) {
	//send to kdb
    int n,sz,cnt;
	struct threadArgs * targs;
	//read from pipe pointer to exch/thread args
	cnt=read(pipe, &targs, sizeof(struct threadArgs *));
	if (cnt==sizeof(targs)) {
		pthread_mutex_lock(&targs->mutex);
		K kdata=kpn(targs->mem.memory,targs->mem.size);
		K sdata=kf(targs->tottime);
		K exch=ks(ss(targs->exch));
		K sym=ks(ss(targs->sym));
		K res = k(0, targs->kcallbk, exch,sym,kdata,sdata,(K) 0);
		r0(res);
		pthread_mutex_unlock(&targs->mutex);
	} else {
		fprintf(stderr, "Something wrong!! Packet length:%0d \n", cnt); 
	}
	return (K)0;
}

char * getcurlproxyurl(struct threadArgs * myargs) {
		return "empty";
}
int getcurlproxyport(struct threadArgs * myargs) {
		return 0;
}

void *exchthread(void *args) {
	struct threadArgs * myargs = (struct threadArgs *)args;
	myargs->mem.memory = malloc(50*1024*1024);  /* will be grown as needed by the realloc above */ 
	myargs->mem.size = 0;    /* no data at this point */ 
	pthread_mutex_init(&myargs->mutex, NULL);
	CURL *curl;
	char * curproxyurl;
	int curproxyport;
	while (1) {
		myargs->mem.size = 0;    /* no data at this point */ 
		/* init the curl session */ 
		curl = curl_easy_init();
		/* send all data to this function  */ 
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
		/* we pass our 'chunk' struct to the callback function */ 
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&myargs->mem);
		/* some servers don't like requests that are made without a user-agent
		 field, so we provide one */ 
		curl_easy_setopt(curl, CURLOPT_USERAGENT, "libcurl-agent/1.0");
		if (myargs->useproxy) {
			curproxyurl = getcurlproxyurl(myargs);
			curproxyport = getcurlproxyport(myargs);
			curl_easy_setopt(curl, CURLOPT_PROXY, curproxyurl);
			curl_easy_setopt(curl, CURLOPT_PROXYPORT, curproxyport);
		}
		curl_easy_setopt(curl, CURLOPT_TIMEOUT, 20);
		/* specify URL to get */ 
		curl_easy_setopt(curl, CURLOPT_URL, myargs->url);
		pthread_mutex_lock(&myargs->mutex);
		/* get it! */ 
		//fprintf(stderr, "curl_easy_perform() %s\n",myargs->url);
		res = curl_easy_perform(curl);
		//get curl opts for time taken
		/* check for errors */ 
		if(res != CURLE_OK) {
			// mark this proxy as potentially bad
			fprintf(stderr, "curl_easy_perform() %s, failed: %s\n",myargs->url, curl_easy_strerror(res));
			myargs->tottime=-1.0; //indidate
		}
		else {
			//write to pipe pointer to exch thread args, so kdb callback can grab exch and kdb callback info
			write(myargs->kpipe[1],&myargs,sizeof(struct threadArgs *));
			res = curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &myargs->tottime);
		}
		pthread_mutex_unlock(&myargs->mutex);
		/* cleanup curl stuff */ 
		curl_easy_cleanup(curl);
		if (myargs->pollfreq) {
			sleep(myargs->pollfreq);
		}
	}
}
static int curl_glob_init = 0;

extern K kx_exch_init(K exchnm,K sym,K proxyl, K cb,K urlob, K pollf) {
    struct threadArgs * args = (struct threadArgs *)malloc(sizeof(struct threadArgs));
	strcpy(args->exch,exchnm->s);
	strcpy(args->url,urlob->s);
	strcpy(args->sym,sym->s);
	strcpy(args->proxyl,proxyl->s);
	strcpy(args->kcallbk,cb->s);
	args->useproxy = 0;
	args->pollfreq = pollf->i;
	if (!curl_glob_init)  {
		curl_global_init(CURL_GLOBAL_ALL);
		curl_glob_init=1;
	}
    if (0 > pipe(args->kpipe)) {
		fprintf(stderr, "pipe error, failed: %s\n",exchnm->s);
		return ks((S) "ERROR");
    }
	sd1(args->kpipe[0], kcallback); //main data pipe
    int rc = pthread_create(&threads[thrdcnt], NULL, exchthread, (void *) args);
	thrdcnt++;
	return ks((S) "OK");
}

#ifdef __cplusplus
}
#endif
