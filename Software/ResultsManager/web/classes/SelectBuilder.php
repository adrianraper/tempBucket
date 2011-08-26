<?php
/**
 * A very simple class that allows SQL queries to be built up nicely within an object rather than fiddling with a string
 */

class SelectBuilder {
	
	var $selects;
	var $from;
	var $wheres;
	var $orWheres;
	var $groups;
	var $orders;
	
	function SelectBuilder() {
		$this->selects = array();
		$this->wheres = array();
		$this->orWheres = array();
		$this->groups = array();
		$this->orders = array();
	}
	
	/**
	 * Set the from clause of the SQL query
	 *
	 * @param from The from clause
	 */
	public function setFrom($from) {
		$this->from = $from;
	}
	
	/**
	 * Add a column to SELECT
	 *
	 * @param select The select clause to add
	 */
	public function addSelect($select) {
		$this->selects[] = $select;
	}
	
	/**
	 * Add a condition to WHERE
	 *
	 * @param where The condition to add
	 */
	public function addWhere($where, $or = false) {
		if ($or) {
			$this->orWheres[] = $where;
		} else {
			$this->wheres[] = $where;
		}
	}
	
	/**
	 * Add a grouping to GROUP BY
	 *
	 * @param group The grouping to add
	 */
	public function addGroup($group) {
		$this->groups[] = $group;
	}
	
	/**
	 * Add an ordering to ORDER BY
	 *
	 * @param order The ordering to add
	 * It would be great to not worry about adding an order clause twice.
	 */
	public function addOrder($order, $direction=null) {
		foreach ($this->orders as $existingOrder) {
			if ($existingOrder == $order)
				return;
		}
		if (isset($direction)) 
			$order.=" $direction";
		
		$this->orders[] = $order;
	}
	
	/**
	 * Convert the SelectBuilder to an SQL string ready for execution
	 */
	public function toSQL() {
		// TODO: Possibly add AND/OR/etc support to $wheres if we need it later on
		$sql = "SELECT ".implode(",", $this->selects)." FROM ".$this->from." ";
		
		if (sizeof($this->wheres) > 0) $sql.= "WHERE ".implode(" AND ", $this->wheres)." ";
		if (sizeof($this->orWheres) > 0) $sql.= "AND (".implode(" OR ", $this->orWheres).") ";
		if (sizeof($this->groups) > 0) $sql.= "GROUP BY ".implode(",", $this->groups)." ";
		if (sizeof($this->orders) > 0) $sql.= "ORDER BY ".implode(",", $this->orders)." ";
		
		return $sql;
	}
	
}
?>
