import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Queue;
 
 
class Node 
{
 
 private int missionaries;
 private int cannibals;
 private int boat;
  
 private Node parent;
 private Node otherSide;
  
 private String action;
  
 private String nextArithmetic;
 
 public Node(int missionaries, int cannibals, int boat, String action, String nextArithmetic, Node otherSide)
 {
  this.missionaries = missionaries;
  this.cannibals = cannibals;
  this.boat = boat;
  parent = null;
  this.action = action;
  this.nextArithmetic = nextArithmetic;
  this.otherSide = otherSide;
 }
 
 //no implementation in this constructor
 public Node()
 {
   
 }
  
 public int getMissionaries() 
 {
  return missionaries;
 }
 
 public void setMissionaries(int missionaries) 
 {
  this.missionaries = missionaries;
 }
 
 public int getCannibals() 
 {
  return cannibals;
 }
 
 public void setCannibals(int cannibals) 
 {
  this.cannibals = cannibals;
 }
 
 public int getBoat() 
 {
  return boat;
 }
 
 public void setBoat(int boat) 
 {
  this.boat = boat;
 }
 
 public Node getParent() 
 {
  return parent;
 }
 
 public void setParent(Node parent) 
 {
  this.parent = parent;
 }
 
 public String getAction() 
 {
  return action;
 }
 
 public void setAction(String action) 
 {
  this.action = action;
 }
 
 public String getNextArithmetic() 
 {
  return nextArithmetic;
 }
 
 public void setNextArithmetic(String nextArithmetic) 
 {
  this.nextArithmetic = nextArithmetic;
 }
  
 public Node getOtherSide() 
 {
  return otherSide;
 }
 
 public void setOtherSide(Node otherSide) 
 {
  this.otherSide = otherSide;
 }
}
class MissCannibal 
{
  
  
 public static void main(String[] args) 
 {
  //used to maintain the explored nodes. 
  //This variable ensures that we do not see a node more than once 
  HashMap<String,Boolean> exploredState = new HashMap<String,Boolean>();
   
  //Queue data structure to implement breadth first search
  Queue<Node> breadthFirstQueue = new LinkedList<Node>();
   
  Node otherSide = new Node(0, 0, 0, null, null, null);
   
  Node initialState = new Node(3, 3, 1, null, "substract", otherSide);
   
  //adding initial state to the explored list.
  breadthFirstQueue.add(initialState);
   
  //if removeAction, boat is going from source to destination
  //if !removeAction, boat is coming from destination to source
  boolean removeAction = true;
   
  //list of actions that can be performed
  ArrayList<String> actions = new ArrayList<String>();
   
  actions.add("101");
  actions.add("201");
  actions.add("111");
  actions.add("011");
  actions.add("021");
   
  MissCanibal m = new MissCanibal();
  System.out.println("starting to solve the problem");
  m.reachAndPrintGoal(initialState, exploredState, breadthFirstQueue, removeAction, actions);
 }
  
 public void reachAndPrintGoal(Node initialNode, HashMap<String,Boolean> exploredState, Queue<Node> breadthFirstQueue, boolean removeAction, ArrayList<String> actions)
 {
  boolean reachedFinalGoal = false;
   
  Node finalNode = null;
   
  while (!breadthFirstQueue.isEmpty() && !reachedFinalGoal)
  {
   Node node = breadthFirstQueue.poll();
    
   for (String currentAction: actions)
   {
    if (node.getNextArithmetic().equalsIgnoreCase("substract"))
    {
     int missionaries = node.getMissionaries() - Integer.parseInt(currentAction.charAt(0) + ""); 
     int cannibals = node.getCannibals() - Integer.parseInt(currentAction.charAt(1) + "");
     int boat = node.getBoat()- Integer.parseInt(currentAction.charAt(2) + "");
      
     int otherMissionaries = node.getOtherSide().getMissionaries() + Integer.parseInt(currentAction.charAt(0) + ""); 
     int otherCannibals = node.getOtherSide().getCannibals() + Integer.parseInt(currentAction.charAt(1) + "");
      
     if (missionaries == 0 && cannibals == 0)
     {
      System.out.println("reached the final goal state");
      Node otherSideNode = new Node(0, 0, 0, null, null, null);
      Node newNode = new Node(0, 0, 0, currentAction, "add", otherSideNode);
      newNode.setParent(node);
      breadthFirstQueue.add(newNode);
       
      finalNode = newNode;
      reachedFinalGoal = true;
      break;
     }
      
     if (missionaries >= 0 && cannibals >= 0 && (missionaries > 0 && (missionaries - cannibals >= 0)) || (missionaries == 0 && cannibals >= 0) && otherMissionaries <= 3 && otherCannibals <= 3)
     {
      if ((otherMissionaries > 0 && (otherMissionaries - otherCannibals >= 0)) || (otherMissionaries == 0 && otherCannibals >= 0))
      {
       String newState = "" + missionaries + cannibals;
       if (!exploredState.containsKey(newState))
       {
        Node otherSideNode = new Node(otherMissionaries, otherCannibals, 1, null, null, null);
         
        Node newNode = new Node(missionaries, cannibals, boat, currentAction, "add", otherSideNode);
        newNode.setParent(node);
        breadthFirstQueue.add(newNode);
       }
      }
       
     }
    }
    else if (node.getNextArithmetic().equalsIgnoreCase("add"))
    {
     int missionaries = node.getMissionaries() + Integer.parseInt(currentAction.charAt(0) + ""); 
     int cannibals = node.getCannibals() + Integer.parseInt(currentAction.charAt(1) + "");
     int boat = node.getBoat() + Integer.parseInt(currentAction.charAt(2) + "");
      
     int otherMissionaries = node.getOtherSide().getMissionaries() - Integer.parseInt(currentAction.charAt(0) + ""); 
     int otherCannibals = node.getOtherSide().getCannibals() - Integer.parseInt(currentAction.charAt(1) + "");
      
     if (missionaries == 0 && cannibals == 0)
     {
      System.out.println("reached the final goal state");
      Node otherSideNode = new Node(0, 0, 0, null, null, null);
      Node newNode = new Node(0, 0, 0, currentAction, "add", otherSideNode);
      newNode.setParent(node);
      breadthFirstQueue.add(newNode);
       
      finalNode = newNode;
      reachedFinalGoal = true;
      break;
     }
      
     if (missionaries <= 3 && cannibals <= 3 && (missionaries > 0 && (missionaries - cannibals >= 0)) || (missionaries == 0 && cannibals >= 0) && otherMissionaries >= 0 && otherCannibals >= 0)
     {
      if ((otherMissionaries > 0 && (otherMissionaries - otherCannibals >= 0)) || (otherMissionaries == 0 && otherCannibals >= 0))
      {
       String newState = "" + missionaries + cannibals;
       if (!exploredState.containsKey(newState))
       {
        Node otherSideNode = new Node(otherMissionaries, otherCannibals, 1, null, null, null);
        Node newNode = new Node(missionaries, cannibals, boat, currentAction, "substract", otherSideNode);
        newNode.setParent(node);
        breadthFirstQueue.add(newNode);
       }
      }
     }
    }
   }
  }
   
  if (finalNode == null)
  {
   System.out.println("cannot find the solution");
  }
  else
  {
   System.out.println("S  D");
   while (finalNode.getParent() != null)
   {
    System.out.println("" + finalNode.getMissionaries() + finalNode.getCannibals() + " " + finalNode.getOtherSide().getMissionaries() + finalNode.getOtherSide().getCannibals());
    finalNode = finalNode.getParent();
   }
   System.out.println("" + finalNode.getMissionaries() + finalNode.getCannibals() + " 00 is the initial node");
  }
 }
}
