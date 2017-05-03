package server;

import massim.Server;

public class RunServer {

	public static void main(String[] args) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				Server.main(new String[] { "-conf", "conf/SampleConfig.json", "--monitor" });
			}
		}).start();
	}

}
