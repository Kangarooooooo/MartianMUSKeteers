// Internal action code for project jasonting

package actions;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Term;

public class distance extends DefaultInternalAction {

	/**
	 *
	 */
	private static final long serialVersionUID = 3098238944781352745L;

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) {
		// execute the internal action
		ts.getAg().getLogger().info("executing internal action 'actions.distance'");

		float distance = 999;

		float x1 = Float.parseFloat(args[0].toString());
		float y1 = Float.parseFloat(args[1].toString());
		float x2 = Float.parseFloat(args[2].toString());
		float y2 = Float.parseFloat(args[3].toString());

		distance = Math.abs(x2 - x1) + Math.abs(y2 - y1);

		boolean returnValue = true;

		returnValue = un.unifies(args[args.length - 1], ASSyntax.parseNumber(String.valueOf(distance)));
		return returnValue;
	}
}
