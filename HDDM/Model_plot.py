# written by Liangying, 20/2/2020
import hddm
import pandas as pd
import matplotlib.pyplot as plt


model = hddm.load('model_avtz2_all_StimCoding_2')
#model.plot_posterior_predictive(figsize=(40,40),save = True, path = "D:\\brainbnu\\haiyang\\hddm\\result\\all_StimCoding\\split_z\\avz")
#model.plot_posteriors(['a', 't', 'v', 'z'],save = True, path = "D:\\brainbnu\\haiyang\\hddm\\result\\all_StimCoding\\avtz2")
# Between group drift rate comparisons

data = hddm.load_csv('D://brainbnu//haiyang//hddm//hddm_all_StimCoding.csv')

#Posterior predictive check
ppc_data = hddm.utils.post_pred_gen(model)
ppc_compare = hddm.utils.post_pred_stats(data, ppc_data)
ppc_stats = hddm.utils.post_pred_stats(data, ppc_data, call_compare=False)

'''
# 0 back
Stress_v_0back, Control_v_0back = model.nodes_db.node[['v(0.stress)', 'v(0.control)']]
print "P_v(Stress_v_0back > Control_v_0back) =", (Stress_v_0back.trace()> Control_v_0back.trace()).mean()
print "P_v(Control_v_0back > Stress_v_0back) =", (Control_v_0back.trace() > Stress_v_0back.trace()).mean()
hddm.analyze.plot_posterior_nodes([Stress_v_0back, Control_v_0back],10)
plt.xlabel('drift-rate')
plt.ylabel('Posterior probability')
plt.title('Posterior of drift-rate group means')
plt.show()


# 2 back
Stress_v_2back, Control_v_2back = model.nodes_db.node[['v(2.stress)', 'v(2.control)']]
print "P_v(Stress_v_2back > Control_v_2back) =", (Stress_v_2back.trace()> Control_v_2back.trace()).mean()
print "P_v(Control_v_2back > Stress_v_2back) =", (Control_v_2back.trace() > Stress_v_2back.trace()).mean()
hddm.analyze.plot_posterior_nodes([Stress_v_2back, Control_v_2back],10)
plt.xlabel('drift-rate')
plt.ylabel('Posterior probability')
plt.title('Posterior of drift-rate group means')
#plt.savefig('hddm_demo_fig_06.pdf')
plt.show()


Stress_v_0back, Control_v_0back = model.nodes_db.node[['v(0.stress)', 'v(0.control)']]
Stress_v_2back, Control_v_2back = model.nodes_db.node[['v(2.stress)', 'v(2.control)']]
hddm.analyze.plot_posterior_nodes([Stress_v_0back, Control_v_0back,Stress_v_2back, Control_v_2back],25)
plt.xlabel('Drift Rate v')
plt.ylabel('Posterior probability')
plt.title('Posterior of drift-rate group means')
plt.savefig('v.png')
plt.show()

Stress_v_2back, Control_v_2back = model.nodes_db.node[['v(2.stress)', 'v(2.control)']]
print "P_v(Stress_v_2back > Control_v_2back) =", (Stress_v_2back.trace()> Control_v_2back.trace()).mean()
print "P_v(Control_v_2back > Stress_v_2back) =", (Control_v_2back.trace() > Stress_v_2back.trace()).mean()


Stress_a_2back, Control_a_2back = model.nodes_db.node[['a(2.stress)', 'a(2.control)']]
print "P_a(Stress_a_2back > Control_a_2back) =", (Stress_a_2back.trace()> Control_a_2back.trace()).mean()
print "P_a(Control_a_2back > Stress_a_2back) =", (Control_a_2back.trace() > Stress_a_2back.trace()).mean()

Stress_t_2back, Control_t_2back = model.nodes_db.node[['t(2.stress)', 't(2.control)']]
print "P_a(Stress_t_2back > Control_t_2back) =", (Stress_t_2back.trace()> Control_t_2back.trace()).mean()
print "P_a(Control_t_2back > Stress_t_2back) =", (Control_t_2back.trace() > Stress_t_2back.trace()).mean()

Stress_a_0back, Control_a_0back = model.nodes_db.node[['a(0.stress)', 'a(0.control)']]
Stress_a_2back, Control_a_2back = model.nodes_db.node[['a(2.stress)', 'a(2.control)']]
hddm.analyze.plot_posterior_nodes([Stress_a_0back, Control_a_0back,Stress_a_2back, Control_a_2back],25)
plt.xlabel('Decision Boundary')
plt.ylabel('Posterior probability')
plt.title('Posterior of decision boundary group means')
plt.savefig('a.eps')
plt.show()'''
