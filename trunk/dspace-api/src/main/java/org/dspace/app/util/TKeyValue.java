/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.util;

/**
 *
 * @author LuckyMan
 */

public class TKeyValue {
    public Object key;
    public Object value;
    public TKeyValue(){}
    public TKeyValue(Object pKey,Object pValue)
    {
        key = pKey;
        value = pValue;
    }
}