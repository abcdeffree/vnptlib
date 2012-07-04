/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.util;

import java.io.IOException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author LuckyMan
 */
public class ExecuteFile {
    public static String FILE_CONVERT_APP_PATH = "E:\\ExecuteFile\\pdftoflashcmd.exe";
    public static void executeFile(String fileExecutePath,ArrayList<TKeyValue> listAgrs)
    {
        try {
            String cmd = fileExecutePath;
            for(TKeyValue kv : listAgrs)
            {
                cmd += kv.key.toString() + kv.value.toString();
            }
            String[] commands = {"cmd","/c",cmd};
            Process process = Runtime.getRuntime ().exec (commands);
        } catch (IOException ex) {
            Logger.getLogger(ExecuteFile.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public static boolean execConvertFileToSWF(String inFilePath,String outFilePath)
    {
        try
        {
            ArrayList<TKeyValue> listArgs = new ArrayList<TKeyValue>();
            listArgs.add(new TKeyValue(" ", inFilePath));
            listArgs.add(new TKeyValue(" ", outFilePath));
            executeFile(FILE_CONVERT_APP_PATH, listArgs);
            return true;
        }catch(Exception ex)
        {
            return false;
        }
        
    }
}





