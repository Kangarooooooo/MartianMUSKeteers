package actions;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import massim.scenario.city.data.Location;

public class closestFinder extends DefaultInternalAction {

	private static final long serialVersionUID = 4514198587500512037L;

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) {
		String role = args[0].toString(); // for flying mode or driving mode
		String[][] places = new String[args.length / 3][3]; // the list will have id,lat,lon,id,lat,lon... so splitting it properly up

		Location callerLocation = Location.parse(args[3].toString(), args[4].toString());

		String closestFacilityId = null;
		double minimumDistance = Integer.MAX_VALUE;

		for (String[] place : places) {
			Location facilityLocation = Location.parse(place[1].toString(), place[2].toString());
			double distance = getDistance(callerLocation, facilityLocation);
			if (distance < minimumDistance) {
				closestFacilityId = place[0];
			}
		}

		if (closestFacilityId != null) {
			boolean returnValue = un.unifies(args[2], Literal.parseLiteral(closestFacilityId));
			return returnValue;
		}
		return true;
	}

	private double getDistance(Location location1, Location location2) {
		double dx = Math.abs(location1.getLat() - location2.getLat());
		double dy = Math.abs(location1.getLon() - location2.getLon());

		return Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));
	}

}
