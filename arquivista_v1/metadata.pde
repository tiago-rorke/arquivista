
void parseMetadata(String[] dataInput) {
    
  // skip the header
  for(int i=1; i<dataInput.length; i++) {    
        
    // parse each line from the CSV file
    String[] data = splitTokens(dataInput[i], ",;");
    
    int id = parseInt(data[0]);
    filenames[id] = data[1];
    
    // skip the first two elements (ID and filename)
    for(int h=2; h<data.length; h++) {
      
      data[h] = trim(data[h]);
      data[h] = data[h].toLowerCase();
      
      // for each element in the line, check to see if it is already in the tags array
      boolean newTag = true;      
      for(int j=0; j<tags.length; j++) {
        if(tags[j].equals(data[h])) {
          newTag = false;
          break;
        }
      }   
      // if it isn't, append it.   
      if(newTag) {
        tags = append(tags, data[h]);
      } 
    }
  }
  
  // sort the tags array
  tags = sort(tags);
    
  // for each tag, search the input data
  for(int i=0; i<tags.length; i++) {
    
    int[] list = new int[0];
    
    // skip the header
    for(int h=1; h<dataInput.length; h++) {
      String line = dataInput[h].toLowerCase();
      String[] find = match(line, tags[i]);
      
      // if the tag is found, add the corresponding id to a list of id's.
      if(find != null) {
        int a = dataInput[h].indexOf(";");
        int id = parseInt(dataInput[h].substring(0,a));
        list = append(list,id);
      }
    }
      
    // then add this list to the associations array
    associations.add(list);
  }  
  
}


// looks for tags with accented characters (à  á  â  ã  ä  å    ç    è  é  ê  ë    ì  í  î  ï    ò  ó  ô  õ  ö    ù  ú  û  ü)
// and replaces them with the unaccented versions
void makeUnaccentedTags() {  
  
  for(int i=0; i<tags.length; i++) {
    
    char tag[] = tags[i].toCharArray();
    boolean accented = false;
    
    for(int h=0; h<tags[i].length(); h++) {
      if(tag[h] >= 224 && tag[h] <= 229) { tag[h] = 'a'; accented = true; }
      if(tag[h] >= 232 && tag[h] <= 235) { tag[h] = 'e'; accented = true; }
      if(tag[h] >= 236 && tag[h] <= 239) { tag[h] = 'i'; accented = true; }
      if(tag[h] >= 242 && tag[h] <= 246) { tag[h] = 'o'; accented = true; }
      if(tag[h] >= 249 && tag[h] <= 252) { tag[h] = 'u'; accented = true; }
      if(tag[h] == 231) { tag[h] = 'c'; accented = true; }
    }
    
    if(accented) {
      String a = new String(tag);
      tags = append(tags, a);
      int[] list = associations.get(i);
      associations.add(list);
    }
    
  }
  
}