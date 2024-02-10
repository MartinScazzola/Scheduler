# **Scheduler**

## **Proceso de compilacion y ejecucion**

La compilación se realiza mediante el comando make en la carpeta principal
del repositorio (/sched).

Se puede ejecutar un proceso mediante el comando
`make run-NOMBRE_PROCESO` o `make run-NOMBRE_PROCESO-nox`. Un ejemplo para la ejecución
es `make run-hello-nox` que correrá el proceso de usuario `user/hello.c`.
Todos los posibles procesos para ser ejecutados se encuentran en la carpeta user.


Se debe agregar al comando de ejecución el flag `RR=true` o `SP=true` dependiendo la implementación
que se desea probar (RR = Round Robin; SP= Scheduler con Prioridades).
Además, para determinar la cantidad de CPUs que se utilizarán en la ejecución
se deberá incluir el flag `CPUS=n`, donde n es la cantidad de CPUs que se quiere utilizar.
Un ejemplo para este caso sería `make run-hello SP=true CPUS=3` ejecutará el proceso de usuario
user/hello.c con el scheduler con prioridades y con 3 CPUs.


## **Capturas de pantalla para visualización de cambio de contexto**

### **El cambio de contexto**
La primera imagen muestra el contenido del `struct TrapFrame` antes de ser quitado de la pila en el context switch (Durante el Modo Kernel)

![Imagen cambio de contexto 1/3](https://cdn.discordapp.com/attachments/1025050435863728163/1117525604502347846/image.png)

La segunda imagen muestra el estado de los registros antes del cambio de contexto (Durante el modo Kernel)

![Imagen cambio de contexto 2/3](https://cdn.discordapp.com/attachments/1025050435863728163/1117597919814627438/image.png)

La tercera imagen muestra el estado de los registros después del cambio de contexto (Durante el modo usuario)

![Imagen cambio de contexto 3/3](https://cdn.discordapp.com/attachments/1025050435863728163/1117532070818873395/image.png)

**Un cambio de contexto es un evento en el cual el procesador cambia de la ejecución de un proceso a otro. Durante este cambio, el procesador debe guardar y restaurar el estado de los registros para asegurar que la ejecución del proceso de usuario anterior pueda ser retomada sin problemas cuando sea necesario.**

**En nuestro caso particular se puede observar como cambia el registro `esp` debido a que tiene que cambiar el stack del kernel al stack del usuario sin perder informacion. Tambien se ve una diferencia respecto `cs` el cual pasa de ring 0 a ring 3, lo que restringe al usuario la posibilidad de realizar determinadas operaciones privilegiadas. Por ultimo se puede observar la diferencia en el `eip` dado que el kernel restaura este registro con la instruccion en la cual se habia quedado el proceso antes del ser desalojado.**

### **Cómo cambia el stack instrucción a instrucción**
![Imagen cambio en stack instrucción a instrucción 1/2](https://cdn.discordapp.com/attachments/1095697655457402992/1110643498220277840/image.png)

![Imagen cambio en stack instrucción a instrucción 2/2](https://cdn.discordapp.com/attachments/1095697655457402992/1110643676545290380/image.png)

## **Scheduler con prioridades**

Para la implementación en este proyecto se utilizó una versión modificada de 
Lottery Scheduling, la cual se encuentra explicada en el siguiente documento:

[OSTEP, Capitulo 9 | SCHEDULING - Proportional Share ](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-sched-lottery.pdf).

El algoritmo se basa en que cada proceso cuente con una cantidad de tickets. Los procesos
más prioritarios tendrán mayor cantidad de tickets y caso contrario para los menos prioritarios.
Luego, se simula una elección al azar como una lotería entre todos los tickets de los procesos y se ejecuta el que 
tenga el número ganador.

Para generar el ticket ganador aleatoriamente se utilizó un PNRG (Pseudo Random Number Generator). Este es un algoritmo que produce una secuencia aparentemente aleatoria de números, pero en realidad, los números generados son deterministas y repetibles si se conocen las condiciones iniciales y el estado interno del generador.

Un PRNG comienza con un valor inicial llamado semilla y utiliza una serie de operaciones matemáticas para generar números sucesivos. Estos números se asemejan a una secuencia aleatoria, pero en realidad son calculados de manera sistemática. A medida que se generan más números, el estado interno del PRNG se actualiza y se utiliza para generar el siguiente número en la secuencia.

El algoritmo se implementó en base al siguiente artículo de la Universidad de Virginia

[Lottery Scheduling Implementation - University of Virginia ](https://www.cs.virginia.edu/~cr4bd/4414/S2019/lottery.html).

En nuestra implementación, dado que no se puede distinguir qué proceso es más prioritario que otro,
todos los procesos inician con una cantidad igual de tickets (100). Luego de ejecutarse algún proceso, este
pierde un ticket, posicionándolo en menor prioridad que los otros procesos.
Este mecanismo se repite 10 veces hasta que en un punto vuelven a subir su prioridad
todos los procesos posibles de ejecutar.

### **Impresión de estadísticas**
Al finalizar cada proceso, se imprimirán las siguientes estadísticas:
- Historial de procesos ejecutados/seleccionados
- Número de llamadas al scheduler
- Número de ejecuciones de cada proceso
- Tiempo de inicio de cada proceso ejecutado

Dada la implementación de JOS, combinada con los cambios realizados en el proyecto, no es posible saber con certeza el momento de finalización de cada ejecución de un proceso. Por lo tanto decidimos 
omitir esa recomendación mostrando unicamente el tiempo de inicio.

## **Ejecución de Pruebas**
Se pueden ejecutar los tests incluídos en el proyecto, los cuales son 20 en total, con el comando:
`make grade RR=true` o `make grade SP=true`.

Las pruebas fueron ejecutadas en el sistema operativo Linux Ubuntu versión 20.04.6

---
También se crearon 4 programas de usuarios para validar la funcionalidad del scheduling con prioridades.
- same_priority.c
- check_set_priority.c
- priority_decrease.c
- priority_increase.c

Las mismas se pueden ejecutar con `make run-user_NOMBRE-nox SP=true` o `make run-user_NOMBRE-nox RR=true`

---
### **Pruebas Round Robin (RR)**
![Pruebas Round Robin](https://cdn.discordapp.com/attachments/1025050435863728163/1117515476394844320/image.png)

### **Pruebas Scheduler con Priodidad usando Lottery Scheduling (SP)**
![Pruebas Scheduler con priodidad](https://media.discordapp.net/attachments/1025050435863728163/1117635129427365908/image.png?width=450&height=608)


