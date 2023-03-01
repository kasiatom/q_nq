### Conda activation  
Bioinformatical tools are installed via conda. To use them conda must be initiated and then the `bio` envirimnent must be activated.
 * Conda initiation (performed only once):  
   ```bash
    conda init
    ```
    The above step to get action requires re-opening of the terminal.  
       
 * Activation of the `bio` environment (every time, when bioinformatical tools are needed):  
    ```bash
    conda activate bio
    ```
    The name of the active environment will appear at the beginning of the prompt.  
  
  ### Creating of the softlinks to the data directories  
  The FASTQ files from the experiment are here: `/mnt/qnap/users/kasia.tomala/dominika/`.  The "genome" files (yeast R64-1-1 reference fasta, bowtie, bwa and GATK indexes) are here: `/mnt/qnap/users/kasia.tomala/genome/`. Both directories can be reached from all IES servers.   
  To use thosethese data files without typing long paths and without creating their extra copies, please create softlinks to both directories in your home directory (the place where you are after logging in). Additionally, create the directory called `working`.

  ```bash
  ln -s  /mnt/qnap/users/kasia.tomala/dominika $HOME/dominika
  ln -s /mnt/qnap/users/kasia.tomala/genome $HOME/genome
  mkdir $HOME/working  
  ```
  
  ### Repository  
  The srcipts used for data analysis will be in the GitHub repository [q_nq](#https://github.com/kasiatom/q_nq). 
  You can get the local version of the repository and also add there your own files:  
  ```bash
  cd $HOME
  git clone https://github.com/kasiatom/q_nq.git ## this will create git directory q_nq in your home directory

  ## to update all files
  cd $HOME/q_nq
  git pull
  ```

### Screen 
Use screen (virtual terminal) to run a long-lasting processes (like alignment or variant calling).
 * Create new screen session:
   ```bash
   screen -S some_name
   ```
 * Activate `bio` environment inside the screen session (if needed), almost always
   ```bash
   conda activate bio
   ```
 * Run the command/script, it is good idea to save the logs to some file  
   ```bash     
   cmd &>my.log
   ```

  * Detach from the screen terminal (the command/srcipt will be executed in the background): <kbd>Ctrl</kbd> + <kbd>a</kbd> + <kbd>d</kbd>
  * To return to the screen session type:
    ```bash
    screen -r some_name
    ```
   * Use `exit` (when inside the screen session) to close and kill it.    